#!/usr/bin/env bash

set -o errexit  # exit script if a command fails
set -o nounset  # exit when script uses undeclared vars
set -o pipefail
#set -o xtrace


action="install"
verbosity=0

function _log() {
    printf "%s\\n" "$*"
}

function _log_debug() {
    if [[ $verbosity == 1 ]]; then
        printf "DEBUG: %s\\n" "$*" 1>&2
    fi
}

function _log_error() {
    printf "%s\\n" "$*" 1>&2
}


function verify_dependencies() {
    _log_debug "verify dependencies"
    if ! [ -x "$(command -v curl)" ]; then
        _log_error "Required command 'curl' is not available."
        return 1
    fi

    if ! [ -x "$(command -v grep)" ]; then
        _log_error "Required command 'grep' is not available."
        return 1
    fi
}

function install_vstest() {
    _log_debug "installing vstest"

    #url="https://www.nuget.org/api/v2/package"
    tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'vstest')

    _log "Downloading package to '$tmpdir'..."
}

function list_vstest_versions() {
    _log_debug "available vstest versions"

    info_url="https://api.nuget.org/v3-flatcontainer/Microsoft.TestPlatform.Portable/index.json"
    _log "Available vstest versions:"
    curl --silent $info_url --stderr - | grep -o -P "^.*\"\\d.*\""
}

function show_usage() {
    printf "Usage: install.sh [OPTION]... DIRECTORY"
    printf "Install vstest runner to DIRECTORY."
    printf "  -v, --version         fetch the specified version of vstest runner"
    printf "  -l, --list            list available versions of vstest runner"
    printf "      --help            display this help and exit\\n"
    printf "Full documentation at <https://spekt.github.io/vstest-get>."
    printf "Please report any issues at <https://github.com/spekt/vstest-get/issues>."
}

function do_action() {
    case "$1" in
        install)
            install_vstest
            ;;
        list)
            list_vstest_versions
            ;;
        help)
            show_usage
            ;;
    esac
}


while [[ $# -ne 0 ]]; do
    case "$1" in
        -l|--list)
            shift
            action="list"
            ;;
        help)
            shift
            action="help"
            ;;
        *)
            _log_error "install.sh: invalid option '$1'"
            printf "Try 'install.sh --help' for more information."
            break
    esac
done


verify_dependencies && do_action $action
