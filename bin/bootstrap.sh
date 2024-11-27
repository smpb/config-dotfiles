#!/bin/sh

SCRIPT_DIR=`dirname $(readlink -f $0)`
ROOT_DIR=`dirname $SCRIPT_DIR`
TESTING=""

while getopts 't' FLAG; do
    case "${FLAG}" in
        t) TESTING="-t" ;;
    esac
done

$SCRIPT_DIR/link.sh $TESTING -s $ROOT_DIR        -d $HOME         -f $SCRIPT_DIR/link.ignore -p
$SCRIPT_DIR/link.sh $TESTING -s $ROOT_DIR/config -d $HOME/.config -f $SCRIPT_DIR/link.ignore
