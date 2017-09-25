#!/bin/bash
set -euo pipefail

KEY="$(cat /etc/secrets/key)"
if [ -z "${KEY}" ]; then
  echo "Cannot unpack secrets because /etc/secrets/key is empty." >&2
  exit 1
fi

find /etc/replicator.d -name \*.toml -delete
for FILE in "/etc/secrets/$(echo -n "$(cat /etc/hostname)" | sha256sum | cut -d' ' -f1)"/*.gpg.b64; do
  OUTFILE="/etc/replicator.d/$(basename "${FILE}" .gpg.b64).toml"
  GPGFILE="$(basename "${FILE}" .b64)"
  base64 -d < "${FILE}" > "${GPGFILE}"
  echo "${KEY}" | gpg --pinentry-mode loopback --quiet --decrypt --passphrase-fd 0 -o "${OUTFILE}" "${GPGFILE}"
  chmod 0600 "${OUTFILE}"
  rm "${GPGFILE}" # cleanup temporary file
done
