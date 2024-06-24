() {
    local dict_validator="
        local -a arg_icon
        local -a arg_icon_color
        local -a arg_title
        local -a arg_title_style

        $(
            __mux-build-validator \
                --scope \
                --location \
                --spec -icon:=arg_icon \
                --spec -icon-color:=arg_icon_color \
                --spec -title:=arg_title \
                --spec -title-style:=arg_title_style
        )

        __mux-validate-info-dict || return 1
    "

    functions[mux-validate-set-info]="$dict_validator"
    function mux-exec-set-info() {
        {
            __mux-write-values

            local -a mux_varnames
            mux_varnames=(${(@k)MuxValues})

            MuxArgs[namespace]="info"
            mux-impl-set-vars
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-update-info]="$dict_validator"
    function mux-exec-update-info() {
        {
            __mux-write-values

            local -a mux_varnames
            mux_varnames=(${(@k)MuxValues})

            MuxArgs[namespace]="info"
            mux-impl-update-vars
        } always {
            __mux-cleanup-fifos
        }
    }

    local list_validator="
        local -a arg_icon
        local -a arg_icon_color
        local -a arg_title
        local -a arg_title_style

        $(
            __mux-build-validator \
                --scope \
                --location \
                --spec -icon=arg_icon \
                --spec -icon-color=arg_icon_color \
                --spec -title=arg_title \
                --spec -title-style=arg_title_style
        )

        local -a mux_varnames
        __mux-validate-info-keys || return 1
    "

    functions[mux-validate-get-info]="$list_validator"
    function mux-exec-get-info() {
        {
            __mux-make-fifos "$mux_varnames[@]"

            MuxArgs[namespace]="info"
            mux-impl-get-vars &!

            private key
            for key in "$mux_varnames[@]"; do
                echo "${key}: $(< "$MuxFifos[$key]")"
            done
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-resolve-info]="$list_validator"
    function mux-exec-resolve-info() {
        {
            __mux-make-fifos "$mux_varnames[@]"

            MuxArgs[namespace]="info"
            mux-impl-resolve-vars &!

            private key
            for key in "$mux_varnames[@]"; do
                echo "${key}: $(< "$MuxFifos[$key]")"
            done
        } always {
            __mux-cleanup-fifos
        }
    }


    local read_entry_validator="$(
        __mux-build-validator \
            --scope \
            --location
    )"

    private key

    for key in icon icon-color title title-style; do
        functions[mux-validate-get-$key]="$read_entry_validator"
        functions[mux-exec-get-$key]="
            {
                __mux-make-fifos $key

                local -a mux_varnames
                mux_varnames=($key)

                mux-impl-get-vars

                (< \$MuxFifos[$key])
            } always {
                __mux-cleanup-fifos
            }
        "

        functions[mux-validate-resolve-$key]="$read_entry_validator"
        functions[mux-exec-resolve-$key]="
            {
                __mux-make-fifos $key

                local -a mux_varnames
                mux_varnames=($key)

                mux-impl-resolve-vars

                (< \$MuxFifos[$key])
            } always {
                __mux-cleanup-fifos
            }
        "

        functions[mux-validate-set-$key]="$(
            __mux-build-validator \
                --scope \
                --location \
                $key
        )"
        functions[mux-exec-set-$key]="
            {
                __mux-write-values
                mux-impl-update-vars
            } always {
                __mux-cleanup-fifos
            }
        "
    done

    function __mux-validate-icon() {
        MuxArgs[icon]="$1"
        MuxValues[icon]="$1"

        if [[ ${#1} -ne 1 ]]; then
            echo "Icon must be exactly one character but was \"$1\"" >&2
            return 1
        fi
    }

    function __mux-validate-icon-color() {
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

    function __mux-validate-title() {
        MuxArgs[title]="$1"
        MuxValues[title]="$1"
        # TODO valid title chars?
    }

    function __mux-validate-title-style() {
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

    function __mux-validate-info-dict() {
        if [[ ${#arg_icon[@]} -gt 0 ]]; then
            __mux-validate-icon "$arg_icon[-1]" || return 1
        fi

        if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
            __mux-validate-icon-color "$arg_icon_color[-1]" || return 1
        fi

        if [[ ${#arg_title[@]} -gt 0 ]]; then
            __mux-validate-title "$arg_title[-1]" || return 1
        fi

        if [[ ${#arg_title_style[@]} -gt 0 ]]; then
            __mux-validate-title-style "$arg_title_style[-1]" || return 1
        fi
    }

    function __mux-validate-info-keys() {
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
}
