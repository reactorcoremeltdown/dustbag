test -f /etc/datasources/ifttt-token && source /etc/datasources/ifttt-token

case $MONIT_PROGRAM_STATUS in
  "1")
    curl -s -X POST -H "Content-Type: application/json" -d '{"value1":"'"$MONIT_SERVICE"'","value2":"'"$MONIT_DESCRIPTION"'","value3":"warning"}' "https://maker.ifttt.com/trigger/incidents/with/key/"$IFTTT_MAKER_TOKEN
    ;;
  "2")
    curl -s -X POST -H "Content-Type: application/json" -d '{"value1":"'"$MONIT_SERVICE"'","value2":"'"$MONIT_DESCRIPTION"'","value3":"failure"}' "https://maker.ifttt.com/trigger/incidents/with/key/"$IFTTT_MAKER_TOKEN
    ;;
esac
