#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

rm -rf "${DRUPAL_SITE_DIR}/files"
mkdir -p "${WODBY_DIR_FILES}/public"
mkdir -p "${WODBY_DIR_FILES}/private"
ln -sf "${WODBY_DIR_FILES}/public" "${DRUPAL_SITE_DIR}/files"

if [[ "${DRUPAL_VERSION}" == "8" ]]; then
    mkdir -p "${WODBY_DIR_FILES}/config/sync_${DRUPAL_FILES_SYNC_SALT}"
fi
