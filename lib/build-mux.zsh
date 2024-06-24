#!/bin/zsh

### Build a mux API compliant zsh function
#
# Within the context of the sourced file, the function register-mux-impl
# is available to add implementations for required hooks.
#
# See the test mux API implementation for example usage.
#
# arg1: the name to give the function
# arg2: the file to source that adds hooks

# @formatter:off
() {

    local dir="$1"
    local func_to_build="$2"
    local file_to_source="$3"

    if [[ -z "$func_to_build" ]]; then
        echo "build-mux: must provide function name" >&2
        return 1
    fi

    if [[ -z "$file_to_source" ]]; then
        echo "build-mux: must provide file to source" >&2
    fi

    local -a required_mux_impls
    required_mux_impls=(
        set-var
        get-var
    )

    local -a mux_cmds
    local -A cmd_parsers
    local -A cmd_impls
    source "$dir/vars.zsh"
    source "$dir/info.zsh"
    source "$dir/registers.zsh"
    source "$dir/tree.zsh"
    source "$dir/tabs.zsh"
    source "$dir/common.zsh"

    function register-mux-impl() {
        local impl_name="$1"
        local impl_func="$2"
        mux_impls[$impl_name]="$(unpack-def $impl_name)"
    }

    function unpack-def() {
        whence -c $1 | sed -e '1d' -e '$d'
    }

    {
        local -a mux_impls
        source "$file_to_source"

        local impl_name
        for impl_name in $required_mux_impls; do
            if [[ -z "$mux_impls[$impl_name]" ]]; then
                echo "build-mux: missing impl $impl_name" >&2
                return 1
            fi
        done

        local impl_func_def='case "$1" in '
        local impl_name impl_val
        for impl_name impl_val in "${(@kv)mux_impls}"; do
            impl_func_def+="
                '${impl_name}')
                    shift
                    ${impl_val}
                    ;;
            "
        done
        impl_func_def+='
            *)
                echo Unknown mux impl $1 >&2
                return 1
                ;;
        esac
        '

        local mux_func_def='case "$1" in '
        local cmd_name
        for cmd_name in $mux_cmds; do
            mux_func_def+="
                ${cmd_name})
                    shift
                    ${cmd_parsers[$cmd_name]}
                    ${cmd_impls[$cmd_name]}
                    ;;
            "
        done
        mux_func_def='
            *)
                echo Unknown mux cmd $1 >&2
                return 1
                ;;
        esac
        '

        eval "
            function __${func_to_build}_impl() {
                $impl_func_def
            }

            function ${func_to_build}() {
                local impl=__${func_to_build}_impl
                $mux_func_def
            }
        "

        } always {
        unfunction register-mux-impl
        unfunction unpack-def
    }

} "${0:a:h}" "$@"
