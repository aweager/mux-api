#!/bin/zsh

test_names=(
    tab-scoped
)

function tab-scoped() {
    function arrange() { }

    function act() {
        "$SUT" delete-var --location t:tab_id name
    }

    function assert() {
        setopt err_return
        assert-empty STDOUT STDERR

        assert-equal \
            cmd_name   delete-var \
            scope      tab \
            location   t:tab_id \
            locationid tab_id \
            varname    name
    }
}
