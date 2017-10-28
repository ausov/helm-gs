#!/bin/bash
#
#? Publish charts directory to Helm repository on Google Storage.
##? Usage: helm gs publish --url <HELM_REPO_URL> [DIR]
##? Arguments:
##?   HELM_REPO_URL - Google Storage URI (gs://...) of chart repository.
##?   DIR - charts directory
#
set -e
set -o pipefail

script_version=$(grep "^#?"  "$0" | cut -c 4-)
script_help=$(grep "^##?" "$0" | cut -c 5-)

POSITIONAL=()
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
	shift # past argument
	;;
	*)
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done

set -- "${POSITIONAL[@]}"

HELM_REPO_DIR="${1:-$(pwd)}"

if [ -z "$HELM_REPO_URL" ]; then
	echo Repository URI required. Example: --url gs://my-repo-bucket >&2
	echo
	echo "$script_help"
	exit 1
fi

# Publish charts
echo
echo "Publishing charts"

# Retrieve latest version info of the index.yaml
current_index=$(gsutil ls -a ${HELM_REPO_URL}/index.yaml 2>/dev/null | tail -n 1 || true)

if [ -z "$current_index" ]; then
	echo "Creating new repository"
	helm repo index \
		--url ${HELM_REPO_URL} \
		${HELM_REPO_DIR}
	gsutil -m \
		cp ${HELM_REPO_DIR}/index.yaml ${HELM_REPO_URL}/index.yaml
else
	current_index_version="${current_index##*#}"
	echo "Updating repository"
	gsutil cp $current_index ${HELM_REPO_DIR}/
	helm repo index \
		--url ${HELM_REPO_URL} \
		--merge ${HELM_REPO_DIR}/index.yaml \
		${HELM_REPO_DIR}
	gsutil -m -h x-goog-if-generation-match:$current_index_version \
		cp ${HELM_REPO_DIR}/index.yaml ${HELM_REPO_URL}/index.yaml
fi

gsutil -m rsync -x "index\.yaml$" ${HELM_REPO_DIR}/ ${HELM_REPO_URL}/

# Acknowledge
echo
ls -l ${HELM_REPO_DIR}
