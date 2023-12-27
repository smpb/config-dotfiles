#!bash

SCRIPT_DIR=`dirname $(readlink -f $0)`
ROOT_DIR=`dirname $SCRIPT_DIR`

for FILE in "$ROOT_DIR"/*
do
  if [[ $SCRIPT_DIR == $FILE ]]
  then
    continue
  fi

  FILENAME=$(basename "$FILE")
  TARGET="$HOME/.$FILENAME"

  if [[ ! -e $TARGET ]]
  then
    echo "Creating a symlink of '$FILE' to '$TARGET'."
    ln -s "$FILE" "$TARGET"
  else
    echo "SKIPPED: '$TARGET' already exists!"
  fi
done

echo "Done."
