() {
    local dict_validator="
        local -a arg_icon
        local -a arg_icon_color
        local -a arg_title
        local -a arg_title_style

        $(
            __mux-build-validator \
                --scope \
                --location \
                --spec -icon:=arg_icon \
                --spec -icon-color:=arg_icon_color \
                --spec -title:=arg_title \
                --spec -title-style:=arg_title_style
        )

        local -A MuxInfo
        __mux-validate-info-dict || return 1
    "

    function __mux-validate-info-dict() {
        if [[ ${#arg_icon[@]} -gt 0 ]]; then
            __mux-validate-icon "$arg_icon[-1]" || return 1
        fi

        if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
            __mux-validate-icon-color "$arg_icon_color[-1]" || return 1
        fi

        if [[ ${#arg_title[@]} -gt 0 ]]; then
            __mux-validate-title "$arg_title[-1]" || return 1
        fi

        if [[ ${#arg_title_style[@]} -gt 0 ]]; then
            __mux-validate-title-style "$arg_title_style[-1]" || return 1
        fi
    }

    functions[mux-validate-set-info]="$dict_validator"
    function mux-exec-set-info() {
        mux-impl-set-info
    }

    functions[mux-validate-update-info]="$dict_validator"
    function mux-exec-update-info() {
        mux-impl-update-info
    }

    local list_validator="
        local -a arg_icon
        local -a arg_icon_color
        local -a arg_title
        local -a arg_title_style

        $(
            __mux-build-validator \
                --scope \
                --location \
                --spec -icon=arg_icon \
                --spec -icon-color=arg_icon_color \
                --spec -title=arg_title \
                --spec -title-style=arg_title_style
        )

        local -a mux_info_keys
        __mux-validate-info-keys || return 1
    "

    function __mux-validate-info-keys() {
        if [[ ${#arg_icon[@]} -gt 0 ]]; then
            mux_info_keys+=(icon)
        fi

        if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
            mux_info_keys+=(icon-color)
        fi

        if [[ ${#arg_title[@]} -gt 0 ]]; then
            mux_info_keys+=(title)
        fi

        if [[ ${#arg_title_style[@]} -gt 0 ]]; then
            mux_info_keys+=(title-style)
        fi
    }

    functions[mux-validate-get-info]="$list_validator"
    function mux-exec-get-info() {
        mux-impl-get-info
    }

    local read_entry_validator="$(
        __mux-build-validator \
            --scope \
            --location
    )"

    local key cut_pos
    private -a info_entries
    info_entries=(
        icon
        icon-color
        title
        title-style
    )

    for key in "${info_entries[@]}"; do
        ((cut_pos = ${#key} + 2))

        functions[mux-validate-get-$key]="$read_entry_validator"
        functions[mux-exec-get-$key]="
            local -a mux_info_keys
            mux_info_keys=($key)
            mux-impl-get-info \
                | grep ^$key \
                | cut -c ${cut_pos}-
        "

        functions[mux-validate-resolve-$key]="$read_entry_validator"
        functions[mux-exec-resolve-$key]="
            local -a mux_info_keys
            mux_info_keys=($key)
            mux-impl-resolve-info \
                | grep ^$key \
                | cut -c ${cut_pos}-
        "

        functions[mux-validate-set-$key]="$(
            local -A MuxInfo
            __mux-build-validator \
                --scope \
                --location \
                $key
        )"

        functions[mux-exec-set-$key]="
            mux-impl-update-info
        "
    done

    function __mux-validate-icon() {
        MuxArgs[icon]="$1"
        MuxInfo[icon]="$1"

        if [[ ${#1} -ne 1 ]]; then
            echo "Icon must be exactly one character but was \"$1\"" >&2
            return 1
        fi
    }

    function __mux-validate-icon-color() {
        MuxArgs[icon-color]="$1"
        MuxInfo[icon-color]="$1"

        local -a color_names
        color_names=(black red green yellow blue magenta cyan white)

        if (($color_names[(Ie)$1])); then
            return 0
        elif [[ $1 =~ '^[0-9]+$' ]]; then
            if [[ $1 -le 255 ]]; then
                return 0
            fi
        elif [[ $1 =~ '^#([0-9]|[a-f]){6}$' ]]; then
            return 0
        fi

        echo "Icon color must be one of the 8 ANSI colors, a number from 0-255, or a hex code #ffffff" >&2
        return 1
    }

    function __mux-validate-title() {
        MuxArgs[title]="$1"
        MuxInfo[title]="$1"
        # TODO valid title chars?
    }

    function __mux-validate-title-style() {
        MuxArgs[title-style]="$1"
        MuxInfo[title-style]="$1"

        local -a allowed_title_styles
        allowed_title_styles=(default italic)
        if (($allowed_title_styles[(Ie)$1])); then
            return 0
        fi

        echo "Title style must be one of ($allowed_title_styles[*]) but was: '$1'"
        return 1
    }
}
