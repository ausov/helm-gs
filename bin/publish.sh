#!/usr/bin/env sh
#
#? Publish charts directory to Helm repository on Google Storage.
##? Usage: helm gs publish --url <HELM_REPO_URL> <DIR>
##? Arguments:
##?   HELM_REPO_URL - Google Storage URI (gs://...) of chart repository.
##?   DIR - Charts directory
#
set -eo pipefail

script_version=$(grep "^#?"  "$0" | cut -c 4-)
script_help=$(grep "^##?" "$0" | cut -c 5-)

HELM_REPO_DIR=''

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
	--url)
		HELM_REPO_URL="$2"
		shift # past argument
		shift # past value
		;;
	--help)
		echo "$script_version"
		echo
		echo "$script_help"
		echo
		exit 0
		;;
	*)
		if [ -n "${HELM_REPO_DIR}" ]; then
			echo "Invalid argument: '$1'" >&2
			echo "Run with '--help' for more info" >&2
			exit 1
		fi
		[ -z "${HELM_REPO_DIR}" ] && HELM_REPO_DIR="$1"
		shift # past argument
		;;
esac
done

if [ -z "${HELM_REPO_URL:-}" ]; then
	echo "Repository URI required. Example: --url gs://my-repo-bucket" . >&2
	echo "Run with '--help' for more info" >&2
	exit 1
fi
if [ -z "${HELM_REPO_DIR}" ]; then
	echo "Charts directory required" >&2
	echo "Run with '--help' for more info" >&2
	exit 1
fi
if ! [ -d "${HELM_REPO_DIR}" ]; then
	echo "Charts directory '${HELM_REPO_DIR}' does not exists" >&2
	echo "Run with '--help' for more info" >&2
	exit 1
fi

# Publish charts
echo
echo "Publishing charts"

# Retrieve latest version info of the index.yaml
current_index=$(gsutil ls -a ${HELM_REPO_URL}/index.yaml 2>/dev/null | tail -n 1 || true)

if [ -z "${current_index}" ]; then
	echo "Creating new repository"
	helm repo index \
		--url ${HELM_REPO_URL} \
		"${HELM_REPO_DIR}"
	gsutil -m \
		cp "${HELM_REPO_DIR}/index.yaml" ${HELM_REPO_URL}/index.yaml
else
	current_index_version="${current_index##*#}"
	echo "Updating repository"
	gsutil cp $current_index "${HELM_REPO_DIR}/"
	helm repo index \
		--url ${HELM_REPO_URL} \
		--merge "${HELM_REPO_DIR}/index.yaml" \
		"${HELM_REPO_DIR}"
	gsutil -m -h x-goog-if-generation-match:$current_index_version \
		cp ${HELM_REPO_DIR}/index.yaml ${HELM_REPO_URL}/index.yaml
fi

gsutil -m rsync -x "index\.yaml$" "${HELM_REPO_DIR}" ${HELM_REPO_URL}

# Acknowledge
echo
ls -l "${HELM_REPO_DIR}"
