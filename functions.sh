#!/usr/bin/env bash

function pre_install()
{
    mkdir -p "$src_dir" || return $?
    mkdir -p "${install_dir%/*}" || return $?
}

function install_deps()
{
    local packages=($(fetch "dependencies" "$package_manager" || return $?))
    if (( ${#packages[@]} > 0)); then
        log "Installing dependencies for R $r_version ..."
        install_packages "${packages[@]}" || return $?
    fi

    install_optional_deps || return $?
}

function download_r()
{
    log "Downloading $r_url into $src_dir ..."
    download "$r_url" "$src_dir/$r_archive" || return $?
}

function extract_r()
{
    log "Extracting $r_archive to $src_dir/$r_dir_name ..."
    extract "$src_dir/$r_archive" "$src_dir" || return $?
}

function configure_r()
{
    log "Configuring R $r_version ..."
    case "$package_manager" in
        brew)
            opt_dir="$(brew --prefix gcc)"
            ;;
    esac

    ./configure --prefix="$install_dir" \
                "${opt_dir:+--}" \
                "${configure_opts[@]}" || return $?
}

function compile_r()
{
    log "Compiling R $r_version ..."
    make "${make_opts[@]}" || return $?
}

function install_r()
{
    log "Installing R $r_version ..."
    make install || return $?
}
