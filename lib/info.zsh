#### Info commands ####
#
# Required mux impls:
#   - export-vars
#   - import-vars
#   - replace-vars
#   - resolve-vars
#   - list-vars
#   - delete-vars


### Retrieving data ###
mux_cmds+=(
    show-info
    resolve-info
    list-info
)

function @show-info() {
    function build-args-parser() {
        .build-info-list-parser
    }

    function impl() {
        {
            .make-fifos "$mux_varnames[@]"

            MuxArgs[namespace]="info"
            mux-impl-get-vars &!

            private key
            for key in "$mux_varnames[@]"; do
                echo "${key}: $(< "$MuxFifos[$key]")"
            done
        } always {
            .cleanup-fifos
        }
    }
}

function @resolve-info() {
    function build-args-parser() {
        .build-info-list-parser
    }

    function impl() {
        {
            .make-fifos "$mux_varnames[@]"

            MuxArgs[namespace]="info"
            mux-impl-resolve-vars &!

            private key
            for key in "$mux_varnames[@]"; do
                echo "${key}: $(< "$MuxFifos[$key]")"
            done
        } always {
            .cleanup-fifos
        }
    }
}

function @list-info() {
    function build-args-parser() {
        .build-standard-parser # no args
    }

    function impl() {
        local -a reply
        reply=()

        MuxArgs[namespace]="info"
        mux-impl-list-vars

        print -rC1 "$reply[@]"
    }
}

### Modifying data ###
mux_cmds+=(
    set-info
    update-info
    delete-info
)

function @set-info() {
    function build-args-parser() {
        .build-info-dict-parser
    }

    function impl() {
        {
            .write-values

            local -a mux_varnames
            mux_varnames=(${(@k)MuxValues})

            MuxArgs[namespace]="info"
            mux-impl-set-vars
        } always {
            .cleanup-fifos
        }
    }
}

function @update-info() {
    function build-args-parser() {
        .build-info-dict-parser
    }

    function impl() {
        {
            .write-values

            local -a mux_varnames
            mux_varnames=(${(@k)MuxValues})

            MuxArgs[namespace]="info"
            mux-impl-update-vars
        } always {
            .cleanup-fifos
        }
    }
}

function @delete-info() {
    function build-args-parser() {
        .build-info-list-parser
    }

    function impl() {
        MuxArgs[namespace]="info"
        mux-impl-delete-vars
    }
}

### Piping data to/from files ###

# TODO

### Per-key functions ###

() {
    private key
    for key in icon icon-color title title-style; do
        mux_cmds+=(
            get-$key
            resolve-$key
            set-$key
        )

        functions[@get-$key]="
            function build-args-parser() {
                .build-standard-parser \
                    --scope \
                    --location
            }

            functions[impl]='
                {
                    .make-fifos $key

                    local -a mux_varnames
                    mux_varnames=($key)

                    mux-impl-get-vars

                    (< \$MuxFifos[$key])
                } always {
                    .cleanup-fifos
                }
            '
        "

        functions[@resolve-$key]="
            function build-args-parser() {
                .build-standard-parser \
                    --scope \
                    --location
            }

            functions[impl]='
                {
                    .make-fifos $key

                    local -a mux_varnames
                    mux_varnames=($key)

                    mux-impl-resolve-vars

                    (< \$MuxFifos[$key])
                } always {
                    .cleanup-fifos
                }
            '
        "

        functions[@set-$key]="
            functions[build-args-parser]='
                .build-standard-parser \\
                    --scope \\
                    --location \\
                    $key
            '

            function impl() {
                {
                    .write-values
                    mux-impl-update-vars
                } always {
                    .cleanup-fifos
                }
            }
        "
    done
}

### Parsers ###

function .parse-icon() {
    MuxArgs[icon]="$1"
    MuxValues[icon]="$1"

    if [[ ${#1} -ne 1 ]]; then
        echo "Icon must be exactly one character but was \"$1\"" >&2
        return 1
    fi
}

function .parse-icon-color() {
    MuxArgs[icon-color]="$1"
    MuxValues[icon-color]="$1"

    local -a color_names
    color_names=(black red green yellow blue magenta cyan white)

    if (($color_names[(Ie)$1])); then
        return 0
    elif [[ $1 =~ '^[0-9]+$' ]]; then
        if [[ $1 -le 255 ]]; then
            return 0
        fi
    elif [[ $1 =~ '^#([0-9]|[a-f]){6}$' ]]; then
        return 0
    fi

    echo "Icon color must be one of the 8 ANSI colors, a number from 0-255, or a hex code #ffffff" >&2
    return 1
}

function .parse-title() {
    MuxArgs[title]="$1"
    MuxValues[title]="$1"
    # TODO valid title chars?
}

function .parse-title-style() {
    MuxArgs[title-style]="$1"
    MuxValues[title-style]="$1"

    local -a allowed_title_styles
    allowed_title_styles=(default italic)
    if (($allowed_title_styles[(Ie)$1])); then
        return 0
    fi

    echo "Title style must be one of ($allowed_title_styles[*]) but was: '$1'"
    return 1
}

function .parse-info-dict() {
    if [[ ${#arg_icon[@]} -gt 0 ]]; then
        .parse-icon "$arg_icon[-1]" || return 1
    fi

    if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
        .parse-icon-color "$arg_icon_color[-1]" || return 1
    fi

    if [[ ${#arg_title[@]} -gt 0 ]]; then
        .parse-title "$arg_title[-1]" || return 1
    fi

    if [[ ${#arg_title_style[@]} -gt 0 ]]; then
        .parse-title-style "$arg_title_style[-1]" || return 1
    fi
}

function .parse-info-keys() {
    if [[ ${#arg_icon[@]} -gt 0 ]]; then
        mux_varnames+=(icon)
    fi

    if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
        mux_varnames+=(icon-color)
    fi

    if [[ ${#arg_title[@]} -gt 0 ]]; then
        mux_varnames+=(title)
    fi

    if [[ ${#arg_title_style[@]} -gt 0 ]]; then
        mux_varnames+=(title-style)
    fi

    if [[ -z $mux_varnames ]]; then
        mux_varnames=(icon icon-color title title-style)
    fi
}

function .build-info-dict-parser() {
    echo "
        local -a arg_icon
        local -a arg_icon_color
        local -a arg_title
        local -a arg_title_style
    "

    .build-standard-parser \
        --scope \
        --location \
        --spec -icon:=arg_icon \
        --spec -icon-color:=arg_icon_color \
        --spec -title:=arg_title \
        --spec -title-style:=arg_title_style

    echo ".parse-info-dict || return 1"
}

function .build-info-list-parser() {
    echo '
        local -a arg_icon
        local -a arg_icon_color
        local -a arg_title
        local -a arg_title_style
    '

    .build-standard-parser \
        --scope \
        --location \
        --spec -icon=arg_icon \
        --spec -icon-color=arg_icon_color \
        --spec -title=arg_title \
        --spec -title-style=arg_title_style

    echo '
        .parse-info-keys || return 1
    '
}
