#!/bin/zsh

test_names=(
    tab-scoped
)

function tab-scoped() {
    function arrange() { }

    function act() {
        "$SUT" show-var --location t:tab_id name
    }

    function assert() {
        setopt err_return
        assert-empty STDOUT
        assert-empty STDERR

        assert-equal cmd_name show-var
        assert-equal scope tab
        assert-equal location t:tab_id
        assert-equal locationid tab_id
        assert-equal varname name
    }
}
