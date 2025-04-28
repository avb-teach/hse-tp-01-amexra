#!/bin/bash

if [ "$#" -lt 2 ]
then
    echo "Для работы с директориями необходимо заполнить: ./collect_files.sh <входная_директория> <выходная_директория> [--max_depth N]"
    exit 1
fi

IN_DIR="$1"
OUT_DIR="$2"
MAX_DEPTH=""

if [ "$3" == "--max_depth" ] && [ -n "$4" ]
then
    MAX_DEPTH=$4
fi


IN_DIR="$(realpath "$IN_DIR")"
OUT_DIR="$(realpath "$OUT_DIR")"
mkdir -p "$OUT_DIR"


if [ ! -d "$IN_DIR" ]
then
    echo "Входной директории в целом нет"
    exit 2
fi

declare -A COUNT_SAME_NAME

if [ -n "$MAX_DEPTH" ]
then
    FIND_CMD=(find "$IN_DIR" -type f -maxdepth "$MAX_DEPTH")
else
    FIND_CMD=(find "$IN_DIR" -type f)
fi

"${FIND_CMD[@]}" | while read -r FILE
do
    BASENAME=$(basename "$FILE")
    NAME="${BASENAME%.*}"
    EXT="${BASENAME##*.}"
   
    if [ "$NAME" == "$EXT" ]
    then
        EXT=""
    else
        EXT=".$EXT"
    fi

    KEY="$NAME$EXT"
    COUNT=${COUNT_SAME_NAME["$KEY"]}
    if [ -z "$COUNT" ]
    then
        COUNT_SAME_NAME["$KEY"]=1
        DEST="$OUT_DIR/$NAME$EXT"
    else
        DEST="$OUT_DIR/${NAME}${COUNT}$EXT"
        COUNT_SAME_NAME["$KEY"]=$((COUNT + 1))
    fi


    cp -p "$FILE" "$DEST"
done
