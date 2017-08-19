#!/bin/bash
set -euo pipefail
cd "$(readlink -f "$(dirname "$0")")"

for TARGET_DIR in gitea package-query perl-mp3-tag ripit screen-message ttf-montserrat vimprobable2 yaourt; do
  SOURCE_DIR=".vendor-cache/${TARGET_DIR}"

  if [ -d "${SOURCE_DIR}" ]; then
    git -C "${SOURCE_DIR}" remote update origin
  else
    git clone "https://aur.archlinux.org/${TARGET_DIR}.git" "${SOURCE_DIR}"
  fi

  git clean -dXf "${TARGET_DIR}"
  git ls-files -- "${TARGET_DIR}" | xargs -r rm
  git -C "${SOURCE_DIR}" archive --prefix="${TARGET_DIR}/" origin/master | tar xf -
done
