#!/bin/bash

SRC_DIRECTORY=""
DST_DIRECTORY="$HOME"
IGNORE_FILE="link.ignore"
DOT_PREFIX=""
TESTING=false

# Check if a file or directory matches ignore patterns
is_ignored() {
    local ITEM="$1"

    if [ -z "$IGNORE_FILE" ] || [ ! -f "$IGNORE_FILE" ]; then
        return 1
    fi

    while IFS= read -r PATTERN; do
        # Skip empty lines and comments
        [[ -z "$PATTERN" || "$PATTERN" =~ ^# ]] && continue

        # Convert glob patterns to regex
        REGEX=$(echo "$PATTERN" | sed 's/\./\\./g; s/\*/.*/g; s/\?/./g; s/^\/\(.*\)$/^\1$/')

        if [[ "$ITEM" =~ $REGEX ]]; then
            return 0
        fi
    done < "$IGNORE_FILE"

    return 1
}

#

while getopts 's:d:f:pt' FLAG; do
    case "${FLAG}" in
        s) SRC_DIRECTORY="${OPTARG}" ;;
        d) DST_DIRECTORY="${OPTARG}" ;;
        f) IGNORE_FILE="${OPTARG}" ;;
        p) DOT_PREFIX="." ;;
        t) TESTING=true ;;
        *) echo "Usage: $0 -s <source-path> -d <destination-path> [-f ignore-file] [-p] [-t]"
           exit 1 ;;
    esac
done

for DIR in {$SRC_DIRECTORY,$DST_DIRECTORY}; do
    if [ ! -d "$DIR" ]; then
        echo "ERROR: Directory '$DIR' does not exist."
        exit 1
    fi
done

find "$SRC_DIRECTORY" -mindepth 1 -maxdepth 1 | while read -r ITEM; do
    RELATIVE_PATH=${ITEM#"$SRC_DIRECTORY/"}

    if is_ignored "$RELATIVE_PATH"; then
        continue
    fi

    TARGET="$DST_DIRECTORY/$DOT_PREFIX$(basename "$RELATIVE_PATH")"

    if [[ ! -e $TARGET ]]
    then
      echo "Creating a symlink of '$ITEM' to '$TARGET'"
      if [ "$TESTING" = false ]; then
        ln -s "$ITEM" "$TARGET"
      fi
    else
      echo "SKIPPED: '$TARGET' already exists!"
    fi
done
