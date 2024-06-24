function __mux-build-validator() {
    private -a arg_val_allowed_scopes
    private -a arg_val_scope
    private -a arg_val_location
    private -a arg_val_varargs
    private -a arg_val_spec

    zmodload zsh/zutil
    zparseopts -D -E -F -- \
        {s,t,p,b}+=arg_val_allowed_scopes \
        -scope=arg_val_scope \
        -location=arg_val_location \
        -varargs=arg_val_varargs \
        -spec+:-=arg_val_spec ||
    return 1

    private setup=''
    private opt_specs=""
    private validators=""
    private positional_arg_names=("$@")

    private -a allowed_scopes
    private entry
    for entry in $arg_val_allowed_scopes; do
        case "$entry" in
            -s)
                allowed_scopes+=(session)
                ;;
            -t)
                allowed_scopes+=(tab)
                ;;
            -p)
                allowed_scopes+=(pane)
                ;;
            -b)
                allowed_scopes+=(buffer)
                ;;
            *)
                :
                ;;
        esac
    done

    if [[ ! -z $arg_val_scope ]]; then
        setup+='
            private -a arg_scope
        '
        opt_specs+=' {s,t,p,b}=arg_scope -scope:=arg_scope'
        validators+='
            __mux-validate-scope "$arg_scope[-1]" || return 1
        '
    fi

    if [[ ! -z $arg_val_location ]]; then
        setup+='
            private -a arg_location
        '
        opt_specs+=' {l,-location}:=arg_location'
        validators+='
            __mux-validate-location "$arg_location[-1]" || return 1
        '
    fi

    if [[ ! -z $arg_val_scope && ! -z $arg_val_location ]]; then
        validators+='
            if [[ -z $MuxArgs[scope] && -z $MuxArgs[location] ]]; then
                echo "One of scope or location is required" >&2
                return 1
            fi
        '
    elif [[ ! -z $arg_val_scope ]]; then
        validators+='
            if [[ -z $MuxArgs[scope] ]]; then
                echo "Scope is required" >&2
                return 1
            fi
        '
    fi

    if [[ -n $allowed_scopes ]]; then
        validators+="
            private -a allowed_scopes
            allowed_scopes=($allowed_scopes)
            if ! [[ -z \$MuxArgs[scope] || \$allowed_scopes[(Ie)\$MuxArgs[scope]] -gt 0 ]]; then
                echo 'Only ($allowed_scopes) scopes are allowed' >&2
                return 1
            fi
        "
    fi

    private spec
    for spec in $arg_val_spec; do
        opt_specs+=" ${spec:6}"
    done

    if [[ -z $arg_val_varargs ]]; then
        private num_args="${#positional_arg_names}"
        if [[ $num_args -eq 0 ]]; then
            validators+='
                if [[ $# -ne 0 ]]; then
                    echo "$MuxArgs[cmd]: expected 0 arguments but received $#: ($*)" >&2
                    return 1
                fi
            '
        else
            validators+="
                if [[ \$# -ne $num_args ]]; then
                    echo \"\$MuxArgs[cmd]: expected $num_args argument(s) ($positional_arg_names[*]) but received \$#: (\$*)\" >&2
                    return 1
                fi
            "
        fi
    fi

    private index=1
    private arg_name
    for arg_name in $positional_arg_names; do
        validators+="
            __mux-validate-$arg_name \"\$$index\" || return 1
        "
        ((index ++))
    done

    echo "
        $setup

        zmodload zsh/zutil
        zparseopts -D -E -F -- $opt_specs || return 1

        $validators
    "
}

function __mux-validate-scope() {
    if [[ -z "$1" ]]; then
        return
    fi

    private scope_key="$1"
    private -A valid_scopes
    valid_scopes=(
        session session
        -s session
        tab tab
        -t tab
        pane pane
        -p pane
        buffer buffer
        -b buffer
    )

    MuxArgs[scope]="$valid_scopes[$scope_key]"
    if [[ -z "$MuxArgs[scope]" ]]; then
        echo "Invalid scope: '$scope_key'" >&2
        return 1
    fi
}

function __mux-validate-location() {
    if [[ -z "$1" ]]; then
        return
    fi

    private location="$1"
    MuxArgs[location]="$location"
    private location_prefix="${location:0:2}"
    private location_scope

    case "$location_prefix" in
        "s:")
            if [[ "${#location}" -ne 2 ]]; then
                echo "Session locations must exactly match 's:'" >&2
                return 1
            fi
            location_scope="session"
            ;;
        "t:")
            location_scope="tab"
            ;;
        "p:")
            location_scope="pane"
            ;;
        "b:")
            location_scope="buffer"
            ;;
        *)
            echo "Invalid location '$location'. Must begin with s:, t:, p:, or b:" >&2
            return 1
            ;;
    esac

    if [[ -n $MuxArgs[scope] ]]; then
        if [[ $MuxArgs[scope] != $location_scope ]]; then
            echo "Specified scope '$MuxArgs[scope]' does not match specified location '$location'" >&2
            return 1
        fi
    else
        MuxArgs[scope]="$location_scope"
    fi

    MuxArgs[location-id]="${location:2}"
}

function __mux-validate-value() {
    # Nothing is forbidden
    MuxArgs[value]="$1"
}

function __mux-check-alphanumeric() {
    if [[ "$1" =~ [^a-zA-Z0-9] ]]; then
        return 1
    fi
}
