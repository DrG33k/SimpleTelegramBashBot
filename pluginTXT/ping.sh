
#!/bin/bash
fTXT="ping $fTXT"

function ping {
  if [ ${TAKED_MSG} = '"ping"' ]; then
    fSendTXT "pong"
  fi
}

