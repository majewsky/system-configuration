#!/bin/bash
set -euo pipefail
cd "$(readlink -f "$(dirname "$0")")"

vendor() {
  mkdir -p "${TARGET_DIR}"
  SOURCE_DIR=".vendor-cache/${TARGET_DIR}"

  if [ -d "${SOURCE_DIR}" ]; then
    git -C "${SOURCE_DIR}" remote update origin
  else
    git clone "https://aur.archlinux.org/${TARGET_DIR}.git" "${SOURCE_DIR}"
  fi

  git clean -dXf "${TARGET_DIR}"
  git ls-files -- "${TARGET_DIR}" | xargs -r rm
  git -C "${SOURCE_DIR}" archive --prefix="${TARGET_DIR}/" origin/master | tar xf -
}

if [ $# -eq 0 ]; then
  # default: vendor all packages
  for TARGET_DIR in $(grep -L novendor */PKGBUILD | xargs -n1 dirname); do
    printf '\x1B[1;36m>> \x1B[0;36mVendoring %s...\x1B[0m\n' "${TARGET_DIR}"
    vendor "${TARGET_DIR}"
  done
else
  # if args given: vendor only these packages
  for TARGET_DIR in "$@"; do
    vendor "${TARGET_DIR}"
  done
fi
