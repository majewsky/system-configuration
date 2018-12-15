#!/bin/bash
set -euo pipefail

KEY="$(cat /etc/secrets/key)"
if [ -z "${KEY}" ]; then
  echo "Cannot unpack secrets because /etc/secrets/key is empty." >&2
  exit 1
fi

find /etc/replicator.d -name \*.toml -delete

gpg --pinentry-mode loopback --quiet --decrypt --passphrase-fd 3 -o /etc/replicator.d/unpacked.toml \
  <(base64 -d < "/etc/secrets/$(echo -n "$(cat /etc/hostname)" | sha256sum | cut -d' ' -f1).gpg.b64") \
  3< /etc/secrets/key

chmod 0600 /etc/replicator.d/unpacked.toml
