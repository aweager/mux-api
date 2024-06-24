# Usage:
#   In the below descriptions, a "record" is a name followed by a space and then
#   the value. If the name does not have a value, exclude the space.
#
#   Implement the following functions, then source this file:
#     - $MUX_SESSION_ID
#           location argument corresponding to the session level for this mux
#     - $all_info_keys
#           array of all supported info keys (usually icon icon_color title title_style)
#     - .get()
#           1: namespace (INFO or USER)
#           2: location
#           3...: variable names
#           out: print records separated by null
#           return: error if the location doesn't exist
#     - .resolve()
#           same as .get, except resolve the values
#     - .set()
#           1: namespace (INFO or USER)
#           2: location
#           in: records separated by null
#           return: error if the location doesn't exist
#     - .list()
#           1: namespace (INFO or USER)
#           2: location
#           out: variable names separated by newlines
#     - .list-parents()
#           out: for each parent: <parent socket>\n<location in parent>\n
#
# Then mux-impl is ready for use with posix-executor-loop.sh

zmodload zsh/zutil

source "${0:a:h}/vars.zsh"
source "${0:a:h}/info.zsh"
source "${0:a:h}/tree.zsh"

function mux-impl() {
    local cmd="$1"

    if [[ "$cmd" == "publish" ]]; then
        mux-publish <&0 >&1 2>&2 &
    else
        local object="${1#*-}"
        case "$object" in
            var|vars)
                mux-impl-var "$@"
                ;;
            info)
                mux-impl-info "$@"
                ;;
            parent|parents)
                mux-impl-tree "$@"
                ;;
            *)
                printf 'Unknown mux command %s\n' "$cmd" >&2
                return 1
                ;;
        esac <&0 >&1 2>&2 &
    fi
}
