#!/usr/bin/env sh
#
#? helm gs - Google Storage plugin for Helm
##? Usage: helm gs <command>
##?
##? Commands:
##?   publish - Publish charts repository to Google Storage
#
set -euo pipefail

script_version=$(grep "^#?"  "$0" | cut -c 4-)
script_help=$(grep "^##?" "$0" | cut -c 5-)

function fail() {
	local msg=${@}
	echo "ERROR: $msg"
	exit 1
}

function help() {
	echo "$script_version"
	echo
	echo "$script_help"
	echo
}

trap 'fail "caught signal!' HUP KILL QUIT

case "${1:-}" in
	publish)
		shift
		"$HELM_PLUGIN_DIR/bin/publish.sh" "$@"
		;;
	--help|'')
		help
		;;
	*)
		echo "Error: unknown command \"$1\" for \"helm gs\""
		echo "Run 'helm gs --help' for usage."
		;;
esac

exit 0
