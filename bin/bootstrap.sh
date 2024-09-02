#!/bin/sh

SCRIPT_DIR=`dirname $(readlink -f $0)`
ROOT_DIR=`dirname $SCRIPT_DIR`

function create_links() {
  HIDE_TARGET=true
  TARGET_DIR="$HOME"
  SOURCE_DIR="$ROOT_DIR"

  if [[ ! -z $1 ]]
  then
    HIDE_TARGET=false
    TARGET_DIR="$HOME/.$1"
    SOURCE_DIR="$ROOT_DIR"/"$1"
  fi

  for FILE in "$SOURCE_DIR"/*
  do
    if [[ $FILE = $SCRIPT_DIR || $FILE == *.md || $FILE == *config ]]
    then
      continue
    fi

    FILENAME=$(basename "$FILE")
    TARGET=$([[ $HIDE_TARGET == true ]] && echo "$TARGET_DIR/.$FILENAME" || echo "$TARGET_DIR/$FILENAME")

    if [[ ! -e $TARGET ]]
    then
      echo "Creating a symlink of '$FILE' to '$TARGET'."
      ln -s "$FILE" "$TARGET"
    else
      echo "SKIPPED: '$TARGET' already exists!"
    fi
  done
}

create_links
create_links 'config'

echo "Done."
