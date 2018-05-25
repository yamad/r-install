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
    r_dir="/opt/local/R"
else
    src_dir="$HOME/src"
    r_dir="$HOME/.Rprojs"
fi

source "$r_install_dir/util.sh"
source "$r_install_dir/functions.sh"

#
# Prints usage information for r-install.
#
function usage()
{
	cat <<USAGE
usage: r-install [OPTIONS] [VERSION] [-- CONFIGURE_OPTS ...]]

Options:

	-r, --r-dir DIR	        Directory that contains other installed R versions
	-i, --install-dir DIR	Directory to install R into
	    --prefix DIR        Alias for -i DIR
	    --system		Alias for -i /usr/local
	-s, --src-dir DIR	Directory to download source-code into
	-c, --cleanup		Remove archive and unpacked source-code after installation
	-M, --mirror URL	Alternate mirror to download the R archive from
	-u, --url URL		Alternate URL to download the R archive from
	--no-download		Use the previously downloaded R archive
	--no-verify		Do not verify the downloaded R archive
	--no-extract		Do not re-extract the downloaded R archive
	--no-install-deps	Do not install build dependencies before installing R
	--no-reinstall  	Skip installation if R is detected at location already
	-V, --version		Prints the version
	-h, --help		Prints this message

Examples:

	$ r-install 3.4.4
	$ r-install 3.4.4 -- --with-openssl-dir=...

USAGE
}

function parse_options()
{
    local argv=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--r-dir)
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
            -h|--help)
                usage
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
    install_dir="${install_dir:-$r_dir/$r_version}"

    source "$r_install_dir/functions.sh" || return $?
}
