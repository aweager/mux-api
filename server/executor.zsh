#!/bin/zsh

source "logger.zsh"
zmodload zsh/param/private

log.info Executor initialized

while true; do
    local send
    () {
        trap '
            if [[ -n "$send" ]]; then
                log.trace Completing with error
                echo -n 1 > "$send"
                unset send
            fi
            echo "done"
        ' EXIT

        private STDIO_ARGS
        read STDIO_ARGS
        private -a stdio_args=(${(z)STDIO_ARGS})
        private stdin="$stdio_args[1]"
        private stdout="$stdio_args[2]"
        private stderr="$stdio_args[3]"
        send="$stdio_args[4]"
        private client_pid="$stdio_args[5]"

        log.debug "Client $client_pid requested stdio:" \
                "\n    in  < $stdin" \
                "\n    out > $stdout" \
                "\n    err > $stderr" \
                "\nResult on $send"

        private CMD
        read CMD
        private cmd=(${(z)CMD})

        () {
            "$@"
        } < "$stdin" > "$stdout" 2> "$stderr" "$cmd[@]"
        private result=$?

        log.trace "Writing result $result for client $client_pid"
        echo -n $result > "$send"
        unset send
    }
done
