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

        local -A info_dict
        __mux-validate-info-dict || return 1
    "

    function __mux-validate-info-dict() {
        if [[ ${#arg_icon[@]} -gt 0 ]]; then
            local icon
            __mux-validate-icon "$arg_icon[-1]" || return 1
            info_dict[icon]="$icon"
        fi

        if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
            local iconcolor
            __mux-validate-iconcolor "$arg_icon_color[-1]" || return 1
            info_dict[icon-color]="$iconcolor"
        fi

        if [[ ${#arg_title[@]} -gt 0 ]]; then
            local title
            __mux-validate-title "$arg_title[-1]" || return 1
            info_dict[title]="$title"
        fi

        if [[ ${#arg_title_style[@]} -gt 0 ]]; then
            local titlestyle
            __mux-validate-titlestyle "$arg_title_style[-1]" || return 1
            info_dict[title-style]="$titlestyle"
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

        local -a info_keys
        __mux-validate-info-keys || return 1
    "

    function __mux-validate-info-keys() {
        if [[ ${#arg_icon[@]} -gt 0 ]]; then
            info_keys+=(icon)
        fi

        if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
            info_keys+=(icon-color)
        fi

        if [[ ${#arg_title[@]} -gt 0 ]]; then
            info_keys+=(title)
        fi

        if [[ ${#arg_title_style[@]} -gt 0 ]]; then
            info_keys+=(title-style)
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

    local key cut_pos arg_name
    private -A arg_names
    arg_names=(
        icon icon
        icon-color iconcolor
        title title
        title-style titlestyle
    )

    for key arg_name in "${(@kv)arg_names}"; do
        ((cut_pos = ${#key} + 2))

        functions[mux-validate-get-$key]="$read_entry_validator"
        functions[mux-exec-get-$key]="
            local -a info_keys
            info_keys=($key)
            mux-impl-get-info \
                | grep ^$key \
                | cut -c ${cut_pos}-
        "

        functions[mux-validate-resolve-$key]="$read_entry_validator"
        functions[mux-exec-resolve-$key]="
            local -a info_keys
            info_keys=($key)
            mux-impl-resolve-info \
                | grep ^$key \
                | cut -c ${cut_pos}-
        "

        functions[mux-validate-set-$key]="$(
            __mux-build-validator \
                --scope \
                --location \
                $arg_name
        )"

        functions[mux-exec-set-$key]="
            local -A info_dict
            info_dict[$key]=\"\$$arg_name\"
            mux-impl-update-info
        "
    done

    function __mux-validate-icon() {
        icon="$1"
        if [[ ${#1} -ne 1 ]]; then
            echo "Icon must be exactly one character but was \"$1\"" >&2
            return 1
        fi
    }

    function __mux-validate-iconcolor() {
        iconcolor="$1"
        local -a color_names
        color_names=(black red green yellow blue magenta cyan white)

        if (($color_names[(Ie)$iconcolor])); then
            return 0
        elif [[ $iconcolor =~ '^[0-9]+$' ]]; then
            if [[ $iconcolor -le 255 ]]; then
                return 0
            fi
        elif [[ $iconcolor =~ '^#([0-9]|[a-f]){6}$' ]]; then
            return 0
        fi

        echo "Icon color must be one of the 8 ANSI colors, a number from 0-255, or a hex code #ffffff" >&2
        return 1
    }

    function __mux-validate-title() {
        title="$1"
        # TODO valid title chars?
    }

    function __mux-validate-titlestyle() {
        titlestyle="$1"
        local -a title_styles
        title_styles=(default italic)
        if (($title_styles[(Ie)$titlestyle])); then
            return 0
        fi

        echo "Title style must be one of ($title_styles[*]) but was: '$titlestyle'"
        return 1
    }
}
