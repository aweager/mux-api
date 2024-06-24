#!/bin/zsh

zmodload zsh/param/private

### Build a mux API compliant zsh function
#
# See the test mux API implementation for example usage.
#
# arg1: the name to give the function
# arg2: the file to source that implements required hooks

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

        "$pin_dep" aweager/private-func 48e1e690db96f0578186bcbe81d55b28efecb89c
        source "deps/aweager/private-func/fbin/build-invoker" --invoker "__${func_to_build}-impl" \
            "utils.zsh" \
            "validators.zsh" \
            "vars.zsh" \
            "info.zsh" \
            "registers.zsh" \
            "tree.zsh" \
            "$file_to_source" \
            "main.zsh"

        functions[$func_to_build]="\"__${func_to_build}-impl\" mux \"\$@\""
    } always {
        popd -q
    }
} "${0:a:h}" "$@"
