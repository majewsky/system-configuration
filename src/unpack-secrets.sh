#!/bin/bash
set -euo pipefail

KEY="$(cat /etc/secrets/key)"
if [ -z "${KEY}" ]; then
  echo "Cannot unpack secrets because /etc/secrets/key is empty." >&2
  exit 1
fi

find /etc/replicator.d -name \*.toml -delete
for FILE in "/etc/secrets/$(echo -n "$(cat /etc/hostname)" | sha256sum | cut -d' ' -f1)"/*.gpg; do
  OUTFILE="/etc/replicator.d/$(basename "${FILE}" .gpg).toml"
  echo "${KEY}" | gpg --pinentry-mode loopback --quiet --decrypt --passphrase-fd 0 -o "${OUTFILE}" "${FILE}"
  chmod 0600 "${OUTFILE}"
done
