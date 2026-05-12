#!/bin/bash
# restore-archive.sh — pull a phone-side archive back to Mac and untar
# Usage: restore-archive.sh <ARCHIVE_NAME>  e.g. 01_PROVEN_LINEAGE
set -eu
DEV="${FY25013101C8}"
DEV="${DEV:-FY25013101C8}"
NAME="${1:?usage: $0 <archive-name-without-extension>}"
SRC="/data/local/tmp/Genesis-Archive/${NAME}.tar.gz"
DEST="${2:-$HOME/${NAME}-restored}"
mkdir -p "$DEST"
echo "Pulling $SRC → $DEST.tar.gz"
adb -s "$DEV" pull "$SRC" "$DEST/${NAME}.tar.gz"
echo "Extracting…"
tar -xzf "$DEST/${NAME}.tar.gz" -C "$DEST/"
rm "$DEST/${NAME}.tar.gz"
echo
echo "Restored to: $DEST/"
ls -la "$DEST/" | head
echo
echo "Available archives on phone:"
adb -s "$DEV" shell "ls -la /data/local/tmp/Genesis-Archive/"
