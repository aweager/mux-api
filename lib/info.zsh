function __mux-parse-and-call-info-dict() {
    local -a arg_icon
    local -a arg_icon_color
    local -a arg_title
    local -a arg_title_style

    eval "$(
        __mux-build-validator \
            --scope \
            --location \
            --spec -icon:=arg_icon \
            --spec -icon-color:=arg_icon_color \
            --spec -title:=arg_title \
            --spec -title-style:= arg_title_style
    )"

    local -A info_dict

    if [[ ${#arg_icon[@]} -gt 0 ]]; then
        local icon
        __mux-validate-icon "$arg_icon[-1]" || return 1
        info_dict[icon]="$icon"
    fi

    if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
        local iconcolor
        __mux-validate-icon-color "$arg_icon_color[-1]" || return 1
        info_dict[icon-color]="$iconcolor"
    fi

    if [[ ${#arg_title[@]} -gt 0 ]]; then
        local title
        __mux-validate-title "$arg_title[-1]" || return 1
        info_dict[title]="$title"
    fi

    if [[ ${#arg_title_style[@]} -gt 0 ]]; then
        local titlestyle
        __mux-validate-title-style "$arg_title_style[-1]" || return 1
        info_dict[title-style]="$titlestyle"
    fi

    "${cmd_prefix}${cmd_name}"
}

function __mux-parse-and-call-info-key-list() {
    local -a arg_icon
    local -a arg_icon_color
    local -a arg_title
    local -a arg_title_style

    eval "$(
        __mux-build-validator \
            --scope \
            --location \
            --needs-scope-or-location \
            --spec -icon=arg_icon \
            --spec -icon-color=arg_icon_color \
            --spec -title=arg_title \
            --spec -title-style= arg_title_style
    )"

    local -a info_key_list

    if [[ ${#arg_icon[@]} -gt 0 ]]; then
        info_key_list+=(icon)
    fi

    if [[ ${#arg_icon_color[@]} -gt 0 ]]; then
        info_key_list+=(icon-color)
    fi

    if [[ ${#arg_title[@]} -gt 0 ]]; then
        info_key_list+=(title)
    fi

    if [[ ${#arg_title_style[@]} -gt 0 ]]; then
        info_key_list+=(title-style)
    fi

    "${cmd_prefix}${cmd_name}"
}

function __mux-parse-and-call-get-info-entry() {
    eval "$(
        __mux-build-validator \
            --scope \
            --location \
            --needs-scope-or-location
    )"

    local info_key="${cmd_name:4}"
    local -a info_key_list
    info_key_list=($info_key)

    local get_info_result="$("${cmd_prefix}get-info")"
    echo -n "${get_info_result:((${#info_key} + 1))}"
}

function __mux-parse-and-call-set-info-entry() {
    eval "$(
        __mux-build-validator \
            --scope \
            --location \
            --needs-scope-or-location \
            value
    )"

    local info_key="${cmd_name:4}"
    local value="$1"
    "__mux-validate-$info_key" "$value"

    local -A info_dict
    info_dict[$info_key]="$value"

    "${cmd_prefix}update-info"
}

function __mux-validate-icon() {
    if [[ ${#1} -ne 0 ]]; then
        echo "Icon must be exactly one character but was \"$1\"" >&2
        return 1
    fi
    icon="$1"
}

function __mux-validate-icon-color() {
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

function __mux-validate-title-style() {
    titlestyle="$1"
    local -a title_styles
    title_styles=(default italic)
    if (($title_styles[(Ie)$titlestyle])); then
        return 0
    fi

    echo "Title style must be one of ($title_styles[*]) but was: '$titlestyle'"
    return 1
}
