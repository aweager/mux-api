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

    private dir="$1"
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

    # TODO propertly depend
    source "$dir/../../../private-func/fbin/build-invoker" --invoker __${func_to_build}-impl \
        "$dir/utils.zsh" \
        "$dir/validators.zsh" \
        "$dir/vars.zsh" \
        "$dir/info.zsh" \
        "$dir/registers.zsh" \
        "$file_to_source" \
        "$dir/main.zsh"

    functions[$func_to_build]="__${func_to_build}-impl mux \"\$@\""

} "${0:a:h}" "$@"
