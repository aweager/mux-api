#!/bin/zsh

source "logger.zsh"
setopt monitor

if [[ ! -v FOO_LEVEL ]]; then
    typeset -gx FOO_LEVEL
    FOO_LEVEL=1
else
    ((FOO_LEVEL = $FOO_LEVEL + 1))
fi

if [[ $FOO_LEVEL -lt 3 ]]; then
    log.info "at level $FOO_LEVEL"
    ./foo.zsh &
    wait
fi

log.info "exiting level $FOO_LEVEL"
