#!/bin/bash
OWNERS="188527308" # Questo è il tuo identificativo, per scoprirlo invia un tuo messaggio al bot @JsonDumpBot
HASH="1198316269:AAGvT5OXZRuOJuEHphIr5Bei4LhZsRB4Zr0" # Questo e' l'HASH dato da #BotFather
CHAT="188527308" # Questo è il canale dove veranno inviati i messaggi, crea un canale, invia un messaggio ed inoltralo a @JsonDumpBot

# Controlo la presenza dei programmi che mi serviranno
hash curl 2>/dev/null || { echo >&2 "I require 'curl' but it's not installed. Please type: 'sudo apt install curl'"; exit 1; }
hash jq 2>/dev/null || { echo >&2 "I require 'jq' but it's not installed. Please type: 'sudo apt install jq'"; exit 1; }
hash dirname 2>/dev/null || { echo >&2 "I require 'dirname' but it's not installed. Please type: 'sudo apt install coreutils'"; exit 1; }
hash wget 2>/dev/null || { echo >&2 "I require 'wget' but it's not installed. Please type: 'sudo apt install wget'"; exit 1; }

# Non toccare
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function vReloadPlugins {
  fTXT=" "
  fDOC=" "
  fLOC=" "
  fIMG=" "
  mkdir -p ${DIR}/pluginTXT
  mkdir -p ${DIR}/pluginDOC
  mkdir -p ${DIR}/pluginLOC
  mkdir -p ${DIR}/pluginIMG

  CARTELLE=("${DIR}/pluginTXT" "${DIR}/pluginDOC" "${DIR}/pluginLOC" "${DIR}/pluginIMG")
  for CARTELLA in ${CARTELLE[@]}; do
    if [ -d "$CARTELLA" ]; then
      if [ -n "$(ls -A $CARTELLA/)" ]; then
        for file in $CARTELLA/*; do
          echo " + "$file
          source $file
        done
      fi
    fi
  done
}

# Risponde all'interlocutore con un messaggio 
function fReplyTXT() {
  OWNER=$1
  TEXT=$2
  curl -s --max-time 10 -d "chat_id=${OWNER}&text=${TEXT}" https://api.telegram.org/bot${HASH}/sendMessage > /dev/null
}

# Invia un messaggio 
function fSendTXT() {
  TEXT=$1
  curl -s --max-time 10 -d "chat_id=${CHAT}&text=${TEXT}" https://api.telegram.org/bot${HASH}/sendMessage > /dev/null
}


vReloadPlugins
RESULT=`curl -s -X POST https://api.telegram.org/bot$HASH/getUpdates`
#echo "$RESULT"
LAST_UPDATE=0
NEXT_UPDATE=0
while true; do
  RESULT=`curl -s -X POST https://api.telegram.org/bot$HASH/getUpdates?timeout=180'&'offset=$NEXT_UPDATE`
#  echo "$RESULT"

  TAKED_UPDATE=`echo $RESULT | jq '.result[-1].update_id'`
  if [ ${TAKED_UPDATE} != "null" ]; then
    # C'e' almeno un messaggio
    if [ ${TAKED_UPDATE} -ne ${LAST_UPDATE} ]; then
      echo "$RESULT"
      LAST_UPDATE=$TAKED_UPDATE
      NEXT_UPDATE=$((LAST_UPDATE+1))
      TAKED_FROM_ID=`echo $RESULT | jq '.result[-1].message.from.id'`
      TAKED_CHAT_ID=`echo $RESULT | jq '.result[-1].message.chat.id'`
      TAKED_MESSAGE_ID=`echo $RESULT | jq '.result[-1].message.message_id'`
      TAKED_MSG=`echo $RESULT | jq '.result[-1].message.text'`
      if [ ${OWNERS} == ${TAKED_FROM_ID} ]; then
        TAKED_IMG=`echo $RESULT | jq '.result[-1].message.photo'`
        TAKED_LOC=`echo $RESULT | jq '.result[-1].message.location'`
        TAKED_DOC=`echo $RESULT | jq '.result[-1].message.document'`
        #echo "${TAKED_MSG}"
        if [ "${TAKED_MSG}" == '"/reload"' ]; then
          # Ricarico i plugins
          vReloadPlugins
          TEXT="%F0%9F%90%BE "`hostname -f`" alert!%0a"
          TEXT="$TEXT%E2%9E%96 %F0%9F%94%8C Plugins reloaded!"
          fSendTXT "${TEXT}"
        elif [ "${TAKED_IMG}" != "null" ]; then
          # Ho una immagine
          IMG_ID=`echo $RESULT | jq '.result[-1].message.photo[0].file_id'`
          IMG_SIZE=`echo $RESULT | jq '.result[-1].message.photo[0].file_size'`
          IMG_WIDTH=`echo $RESULT | jq '.result[-1].message.photo[0].width'`
          IMG_HEIGHT=`echo $RESULT | jq '.result[-1].message.photo[0].height'`
          for func in $fIMG; do
            $func $IMG_ID $IMG_SIZE $IMG_WIDTH $IMG_HEIGHT
          done
        elif [ "${TAKED_LOC}" != "null" ]; then
          # Ho una localita'
          LOC_LATITUDE=`echo $RESULT | jq '.result[-1].message.location.latitude'`
          LOC_LONGITUDE=`echo $RESULT | jq '.result[-1].message.location.longitude'`
          for func in $fLOC; do
            $func $LOC_LATITUDE $LOC_LONGITUDE
          done
        elif [ "${TAKED_DOC}" != "null" ]; then
          # Ho un documento
          DOC_ID=`echo $RESULT | jq '.result[-1].message.document.file_id'`
          DOC_NAME=`echo $RESULT | jq '.result[-1].message.document.file_name'`
          DOC_MIME=`echo $RESULT | jq '.result[-1].message.document.mime_type'`
          DOC_SIZE=`echo $RESULT | jq '.result[-1].message.document.file_size'`
          for func in $fDOC; do
            $func $DOC_ID $DOC_NAME $DOC_MIME $DOC_SIZE
          done
        elif [ "${TAKED_MSG}" != "null" ]; then
          # Ho un testo
          for func in $fTXT; do
            $func "$TAKED_MSG"
          done
        fi
      fi
    fi
  fi
done
