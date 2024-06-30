# Usage:
#   In the below descriptions, a "record" is a name followed by a space and then
#   the value. If the name does not have a value, exclude the space.
#
#   Implement the following functions, then source this file:
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
#
# Then mux-impl is ready for use with posix-executor-loop.sh

zmodload zsh/zutil

source "${0:a:h}/vars.zsh"
source "${0:a:h}/info.zsh"
source "${0:a:h}/tree.zsh"

function mux-impl() {
    local cmd="$1"

    local object="${1#*-}"
    case "$object" in
        var|vars)
            mux-impl-var "$@"
            ;;
        info)
            mux-impl-info "$@"
            ;;
        *)
            mux-impl-tree "$@"
            ;;
    esac <&0 >&1 2>&2 &
}
