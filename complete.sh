#!/bin/bash
OWNERS="188527308" # Questo è il tuo identificativo, per scoprirlo invia un tuo messaggio al bot @JsonDumpBot
HASH="1198316269:AAGvT5OXZRuOJuEHphIr5Bei4LhZsRB4Zr0" # Questo e' l'HASH dato da #BotFather
CHAT="188527308" # Questo è il canale dove veranno inviati i messaggi, crea un canale, invia un messaggio ed inoltralo a @JsonDumpBot

TEXT="%F0%9F%90%BE "`hostname -f`" alert!%0a"
TEXT="$TEXT%E2%9E%96 %F0%9F%92%BE Download complete: $TR_TORRENT_NAME"
curl -s --max-time 10 -d "chat_id=${CHAT}&text=${TEXT}" https://api.telegram.org/bot${HASH}/sendMessage > /dev/null

