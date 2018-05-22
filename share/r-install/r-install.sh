#!/usr/bin/env bash

shopt -s extglob

r_install_version="0.1"
r_install_dir="${BASH_SOURCE[0]%/*}"
r_install_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/r-install"

patches=()
configure_opts=()
make_opts=()

if (( UID == 0 )); then
    src_dir="/usr/local/src"
    r_dir="/opt/Rprojs"
else
    src_dir="$HOME/src"
    r_dir="$HOME/.rprojs"
fi

source "$r_install_dir/util.sh"
source "$r_install_dir/functions.sh"


function parse_options()
{
    local argv=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--rprojs-dir)
                r_dir="$2"
                shift 2
                ;;
            -i|--install-dir|--prefix)
                install_dir="$2"
                shift 2
                ;;
            -M|--mirror)
                cran_mirror="$2"
                shift 2
                ;;
            --no-download)
                no_download=1
                shift
                ;;
            --no-extract)
                no_download=1
                no_verify=1
                no_extract=1
                shift
                ;;
            --no-install-deps)
                no_install_deps=1
                shift
                ;;
            -u|--url)
                r_url="$2"
                shift 2
                ;;
            -V|--version)
                echo "r-install: $r_version"
                exit
                ;;
            --)
                shift
                configure_opts=("$@")
                break
                ;;
            -*)
                echo "r-install: unrecognized option $1" >&2
                return 1
                ;;
            *)
                argv+=($1)
                shift
                ;;
        esac
    done

    case ${#argv[*]} in
        1)  r_version="${argv[0]}" ;;
        0)  return 0 ;;
        *)
            echo "r-install: too many arguments: ${argv[*]}" >&2
            return 1
            ;;
    esac
}


function init()
{
    r_cache_dir="$r_install_cache_dir"
    install_dir="${install_dir:-$r_dir/R-$r_version}"

    source "$r_install_dir/functions.sh" || return $?
}
