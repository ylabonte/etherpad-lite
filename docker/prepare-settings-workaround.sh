#!/bin/bash

# This script is a workaround for using environment vars in the config file.
# It can be removed as far as the built-in feature for environment variables in
# in the config file is working (again?). But don't forget to translate your
# settings file to the built-in syntax.

IN_FILE=$1
OUT_FILE=$2

if [ "$IN_FILE" == "" ]; then
  echo "Missing first argument: Input file path"
  exit 1
fi
if [ ! -r "$IN_FILE" ]; then
  echo "Invalid first argument: Cannot read from '$1'"
  exit 1
fi
if [ "$OUT_FILE" == "" ]; then
  OUT_FILE=$IN_FILE
else
  if [ -e $OUT_FILE ] && [ ! -w $OUT_FILE ]; then
    echo "Invalid second argument: '$OUT_FILE' is not a regular file or simply not writable"
    exit 1
  fi
fi

BASE_PATH=$(dirname $OUT_FILE)
FILE_NAME=$(basename $OUT_FILE)
TMP1_FILE="${BASE_PATH}/.${FILE_NAME}.tmp1"
TMP2_FILE="${BASE_PATH}/.${FILE_NAME}.tmp2"
cat $IN_FILE > $TMP1_FILE
for line in $(env); do
  # assignment=$(echo $line | grep "^EP_")
  assignment=$line
  if [ "$assignment" == "" ]; then
    continue
  fi
  envVar=`echo $assignment | awk -F= '{ print $1 }'`
  envVal=`echo $assignment | awk -F= '{ print $2 }'`
  sed -e "s#{{[ ]*${envVar}[ ]*}}#${envVal}#g" $TMP1_FILE > $TMP2_FILE
  cat $TMP2_FILE > $TMP1_FILE
done

cat $TMP1_FILE > $OUT_FILE
rm -f $TMP1_FILE $TMP2_FILE

exit 0
