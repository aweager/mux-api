#!/bin/zsh

zmodload zsh/param/private

### Build a mux API compliant zsh function
#
# See the mock-mux API implementation for a full example.
#
# Usage: source /path/to/build-mux.zsh <func-name> <file>
#
# <func-name>: the name to give the function
# <file>: the file to source that implements required hooks

# @formatter:off
() {
    pushd -q "$1"
    {
        local pin_dep
        if typeset -f pin-dep > /dev/null; then
            pin_dep="pin-dep"
        else
            mkdir -p deps/aweager
            pushd -q deps/aweager
            {
                git clone "git@github.com:aweager/pin-dep.git" &> /dev/null
                pin_dep="$PWD/pin-dep/bin/pin-dep"
            } always {
                popd -q
            }
        fi

        private func_to_build="$2"
        private file_to_source="$3"

        if [[ -z "$func_to_build" ]]; then
            echo "build-mux: must provide function name" >&2
            return 1
        fi

        if [[ -z "$file_to_source" ]]; then
            echo "build-mux: must provide file to source" >&2
            return 1
        fi

        "$pin_dep" aweager/private-func eac9711e8c9173c4cf75638743bde116fbd624b4
        source "deps/aweager/private-func/functions/build-invoker" --invoker "__${func_to_build}-impl" \
            "utils.zsh" \
            "validators.zsh" \
            "vars.zsh" \
            "info.zsh" \
            "registers.zsh" \
            "system.zsh" \
            "tree.zsh" \
            "$file_to_source" \
            "main.zsh"

        functions[$func_to_build]="\"__${func_to_build}-impl\" this-mux \"\$@\""
    } always {
        popd -q
    }
} "${0:a:h}" "$@"
