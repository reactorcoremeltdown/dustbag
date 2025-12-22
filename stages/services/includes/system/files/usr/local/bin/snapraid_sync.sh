#!/bin/bash

#######################################################################
# This is a helper script that keeps snapraid parity info in sync with
# your data and optionally verifies the parity info. Here's how it works:
#   1) Shuts down configured services
#   2) Calls diff to figure out if the parity info is out of sync.
#   3) If parity info is out of sync, AND the number of deleted or changed files exceed
#      X (each configurable), it triggers an alert email and stops. (In case of
#      accidental deletions, you have the opportunity to recover them from
#      the existing parity info. This also mitigates to a degree encryption malware.)
#   4) If parity info is out of sync, AND the number of deleted or changed files exceed X
#      AND it has reached/exceeded Y (configurable) number of warnings, force
#      a sync. (Useful when you get a false alarm above and you can't be bothered
#      to login and do a manual sync. Note the risk is if its not a false alarm
#      and you can't access the box before Y number of times the job is run  to
#      fix the issue... Well I hope you have other backups...)
#   5) If parity info is out of sync BUT the number of deleted files did NOT
#      exceed X, it calls sync to update the parity info.
#   6) If the parity info is in sync (either because nothing changed or after it
#      has successfully completed the sync job, it runs the scrub command to
#      validate the integrity of the data (both the files and the parity info).
#      Note that each run of the scrub command will validate only a (configurable)
#      portion of parity info to avoid having a long running job and affecting
#      the performance of the box.
#   7) Once all jobs are completed, it sends an email with the output to user
#      (if configured).
#
#   Inspired by Zack Reed (http://zackreed.me/articles/83-updated-snapraid-sync-script)
#   Modified version of mtompkins version of my script (https://gist.github.com/mtompkins/91cf0b8be36064c237da3f39ff5cc49d)
#
#######################################################################

######################
#   USER VARIABLES   #
######################

####################### USER CONFIGURATION START #######################

# address where the output of the jobs will be emailed to.
EMAIL_ADDRESS="root@tiredsysadmin.cc"

# Set the threshold of deleted files to stop the sync job from running.
# NOTE that depending on how active your filesystem is being used, a low
# number here may result in your parity info being out of sync often and/or
# you having to do lots of manual syncing.
DEL_THRESHOLD=50
UP_THRESHOLD=500

# Set number of warnings before we force a sync job.
# This option comes in handy when you cannot be bothered to manually
# start a sync job when DEL_THRESHOLD is breached due to false alarm.
# Set to 0 to ALWAYS force a sync (i.e. ignore the delete threshold above)
# Set to -1 to NEVER force a sync (i.e. need to manual sync if delete threshold is breached)
SYNC_WARN_THRESHOLD=-1

# Set percentage of array to scrub if it is in sync.
# i.e. 0 to disable and 100 to scrub the full array in one go
# WARNING - depending on size of your array, setting to 100 will take a very long time!
SCRUB_PERCENT=20
SCRUB_AGE=10

# Set the option to log SMART info. 1 to enable, any other values to disable
SMART_LOG=1

# location of the snapraid binary
SNAPRAID_BIN="snapraid"
# location of the mail program binary
MAIL_BIN="/usr/bin/mutt"

# Telegram
WEBHOOK_URL="https://api.rcmd.space/internal/telegram"
ONE_TIME_TOKEN=$(curl -s -XPOST --data-urlencode "token=`cat /etc/secrets/seed`" https://api.rcmd.space/internal/token/get)

# Misc
SPIN_DOWN=0

function main(){

  ######################
  #   INIT VARIABLES   #
  ######################
  CHK_FAIL=0
  DO_SYNC=0
  EMAIL_SUBJECT_PREFIX="(SnapRAID on `hostname`)"
  GRACEFUL=0
  SYNC_WARN_FILE="/tmp/snapRAID.warnCount"
  SYNC_WARN_COUNT=""
  TMP_OUTPUT="/tmp/snapRAID.out"

  # Capture time
  SECONDS=0

  ###############################
  #   MANAGE DOCKER CONTAINERS  #
  ###############################
  # Set to 0 to not manage any containers.
  MANAGE_SERVICES=0

  # Containers to manage (separated with spaces).
  SERVICES=''

  # Build Services Array...
  service_array_setup

  # Expand PATH for smartctl
  PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

  # Determine names of first content file...
  CONTENT_FILE=`grep -v '^$\|^\s*\#' /etc/snapraid.conf | grep snapraid.content | head -n 1 | cut -d " " -f2`

  # Build an array of parity all files...
  #PARITY_FILES[0]=`cat /etc/snapraid.conf | grep "^[^#;]" | grep parity | head -n 1 | cut -d " " -f 2 | cut -d "," -f 1`
  #PARITY_FILES[1]=`cat /etc/snapraid.conf | grep "^[^#;]" | grep parity | head -n 1 | cut -d " " -f 2 | cut -d "," -f 2`
  #PARITY_FILES[2]=`cat /etc/snapraid.conf | grep "^[^#;]" | grep 2-parity | head -n 1 | cut -d " " -f 2 | cut -d "," -f 1`
  #PARITY_FILES[3]=`cat /etc/snapraid.conf | grep "^[^#;]" | grep 2-parity | head -n 1 | cut -d " " -f 2 | cut -d "," -f 2`
  IFS=$'\n' PARITY_FILES=(`cat /etc/snapraid.conf | grep "^[^#;]" | grep "^\([2-6z]-\)*parity" | cut -d " " -f 2 | tr ',' '\n'`)

##### USER CONFIGURATION STOP ##### MAKE NO CHANGES BELOW THIS LINE ####

  # create tmp file for output
  > $TMP_OUTPUT

  # Redirect all output to file and screen. Starts a tee process
  output_to_file_screen

  # timestamp the job
  echo "SnapRAID Script Job started [`date`]"
  echo
  echo "----------------------------------------"

  # Remove any plex created anomolies
  echo "##Preprocessing"

  # Stop any services that may inhibit optimum execution
  if [ $MANAGE_SERVICES -eq 1 ]; then
    echo "###Stop Services [`date`]"
    stop_services
  fi

  # sanity check first to make sure we can access the content and parity files
  sanity_check

  echo
  echo "----------------------------------------"
  echo "##Processing"

  # Fix timestamps
  chk_zero

  # run the snapraid DIFF command
  echo "###SnapRAID DIFF [`date`]"
  $SNAPRAID_BIN diff
  # wait for the above cmd to finish, save output and open new redirect
  close_output_and_wait
  output_to_file_screen
  echo
  echo "DIFF finished [`date`]"
  JOBS_DONE="DIFF"

  # Get number of deleted, updated, and modified files...
  get_counts

  # sanity check to make sure that we were able to get our counts from the output of the DIFF job
  if [ -z "$DEL_COUNT" -o -z "$ADD_COUNT" -o -z "$MOVE_COUNT" -o -z "$COPY_COUNT" -o -z "$UPDATE_COUNT" ]; then
    # failed to get one or more of the count values, lets report to user and exit with error code
    echo "**ERROR** - failed to get one or more count values. Unable to proceed."
    echo "Exiting script. [`date`]"
    if [ $EMAIL_ADDRESS ]; then
      SUBJECT="$EMAIL_SUBJECT_PREFIX WARNING - Unable to proceed with SYNC/SCRUB job(s). Check DIFF job output."
      send_mail
    fi
    exit 1;
  fi
  echo
  echo "**SUMMARY of changes - Added [$ADD_COUNT] - Deleted [$DEL_COUNT] - Moved [$MOVE_COUNT] - Copied [$COPY_COUNT] - Updated [$UPDATE_COUNT]**"
  echo

  # check if the conditions to run SYNC are met
  # CHK 1 - if files have changed
  if [ $DEL_COUNT -gt 0 -o $ADD_COUNT -gt 0 -o $MOVE_COUNT -gt 0 -o $COPY_COUNT -gt 0 -o $UPDATE_COUNT -gt 0 ]; then
    chk_del

    if [ $CHK_FAIL -eq 0 ]; then
      chk_updated
    fi

    if [ $CHK_FAIL -eq 1 ]; then
      chk_sync_warn
    fi
  else
    # NO, so let's skip SYNC
    echo "No change detected. Not running SYNC job. [`date`] "
    DO_SYNC=0
  fi

  # Now run sync if conditions are met
  if [ $DO_SYNC -eq 1 ]; then
    echo "###SnapRAID SYNC [`date`]"
    $SNAPRAID_BIN sync -q
    #wait for the job to finish
    close_output_and_wait
    output_to_file_screen
    echo "SYNC finished [`date`]"
    JOBS_DONE="$JOBS_DONE + SYNC"
    # insert SYNC marker to 'Everything OK' or 'Nothing to do' string to differentiate it from SCRUB job later
    sed_me "s/^Everything OK/SYNC_JOB--Everything OK/g;s/^Nothing to do/SYNC_JOB--Nothing to do/g" "$TMP_OUTPUT"
    # Remove any warning flags if set previously. This is done in this step to take care of scenarios when user
    # has manually synced or restored deleted files and we will have missed it in the checks above.
    if [ -e $SYNC_WARN_FILE ]; then
      rm $SYNC_WARN_FILE
    fi
    echo
  fi

  # Moving onto scrub now. Check if user has enabled scrub
  if [ $SCRUB_PERCENT -gt 0 ]; then
    # YES, first let's check if delete threshold has been breached and we have not forced a sync.
    if [ $CHK_FAIL -eq 1 -a $DO_SYNC -eq 0 ]; then
      # YES, parity is out of sync so let's not run scrub job
      echo "Scrub job cancelled as parity info is out of sync (deleted or changed files threshold has been breached). [`date`]"
    else
      # NO, delete threshold has not been breached OR we forced a sync, but we have one last test -
      # let's make sure if sync ran, it completed successfully (by checking for our marker text "SYNC_JOB--" in the output).
      if [ $DO_SYNC -eq 1 -a -z "$(grep -w "SYNC_JOB-" $TMP_OUTPUT)" ]; then
        # Sync ran but did not complete successfully so lets not run scrub to be safe
        echo "**WARNING** - check output of SYNC job. Could not detect marker . Not proceeding with SCRUB job. [`date`]"
      else
        # Everything ok - let's run the scrub job!
        echo "###SnapRAID SCRUB [`date`]"
        $SNAPRAID_BIN scrub -p $SCRUB_PERCENT -o $SCRUB_AGE -q
        #wait for the job to finish
        close_output_and_wait
        output_to_file_screen
        echo "SCRUB finished [`date`]"
        echo
        JOBS_DONE="$JOBS_DONE + SCRUB"
        # insert SCRUB marker to 'Everything OK' or 'Nothing to do' string to differentiate it from SYNC job above
        sed_me "s/^Everything OK/SCRUB_JOB--Everything OK/g;s/^Nothing to do/SCRUB_JOB--Nothing to do/g" "$TMP_OUTPUT"
      fi
    fi
  else
    echo "Scrub job is not enabled. Not running SCRUB job. [`date`] "
  fi

  echo
  echo "----------------------------------------"
  echo "##Postprocessing"

  # Moving onto logging SMART info if enabled
  if [ $SMART_LOG -eq 1 ]; then
    echo
    $SNAPRAID_BIN smart
    close_output_and_wait
    output_to_file_screen
  fi

  #echo "Spinning down disks..."
  if [ $SPIN_DOWN -eq 1 ]; then
    $SNAPRAID_BIN down
  fi

  # Graceful restore of services outside of trap - for messaging
  GRACEFUL=1
  if [ $MANAGE_SERVICES -eq 1 ]; then
    restore_services
  fi

  echo "All jobs ended. [`date`] "

  # all jobs done, let's send output to user if configured
  if [ $EMAIL_ADDRESS ]; then
    echo -e "Email address is set. Sending email report to **$EMAIL_ADDRESS** [`date`]"
    # check if deleted count exceeded threshold
    prepare_mail

    ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
    echo
    echo "----------------------------------------"
    echo "##Total time elapsed for SnapRAID: $ELAPSED"

    # Add a topline to email body
    sed_me "1s/^/##$SUBJECT \n/" "${TMP_OUTPUT}"
    send_mail
  fi

  #clean_desc

  exit 0;
}

#######################
# FUNCTIONS & METHODS #
#######################

function sanity_check() {
  if [ ! -e $CONTENT_FILE ]; then
    echo "**ERROR** Content file ($CONTENT_FILE) not found!"
    exit 1;
  fi

  echo "Testing that all parity files are present."
  for i in "${PARITY_FILES[@]}"
    do
      if [ ! -e $i ]; then
        echo "[`date`] ERROR - Parity file ($i) not found!"
        echo "ERROR - Parity file ($i) not found!" >> $TMP_OUTPUT
        exit 1;
      fi
  done
  echo "All parity files found. Continuing..."
}

function get_counts() {
  DEL_COUNT=$(grep -w '^ \{1,\}[0-9]* removed' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
  ADD_COUNT=$(grep -w '^ \{1,\}[0-9]* added' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
  MOVE_COUNT=$(grep -w '^ \{1,\}[0-9]* moved' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
  COPY_COUNT=$(grep -w '^ \{1,\}[0-9]* copied' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
  UPDATE_COUNT=$(grep -w '^ \{1,\}[0-9]* updated' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
}

function sed_me(){
  # Close the open output stream first, then perform sed and open a new tee process and redirect output.
  # We close stream because of the calls to new wait function in between sed_me calls.
  # If we do not do this we try to close Processes which are not parents of the shell.
  exec >&$out 2>&$err
  $(sed -i "$1" "$2")

  output_to_file_screen
}

function chk_del(){
  if [ $DEL_COUNT -lt $DEL_THRESHOLD ]; then
    # NO, delete threshold not reached, lets run the sync job
    echo "There are deleted files. The number of deleted files, ($DEL_COUNT), is below the threshold of ($DEL_THRESHOLD). SYNC Authorized."
    DO_SYNC=1
  else
    echo "**WARNING** Deleted files ($DEL_COUNT) exceeded threshold ($DEL_THRESHOLD)."
    CHK_FAIL=1
  fi
}

function chk_updated(){
  if [ $UPDATE_COUNT -lt $UP_THRESHOLD ]; then
    echo "There are updated files. The number of updated files, ($UPDATE_COUNT), is below the threshold of ($UP_THRESHOLD). SYNC Authorized."
    DO_SYNC=1
  else
    echo "**WARNING** Updated files ($UPDATE_COUNT) exceeded threshold ($UP_THRESHOLD)."
    CHK_FAIL=1
  fi
}

function chk_sync_warn(){
  if [ $SYNC_WARN_THRESHOLD -gt -1 ]; then
    echo "Forced sync is enabled. [`date`]"

    SYNC_WARN_COUNT=$(sed 'q;/^[0-9][0-9]*$/!d' $SYNC_WARN_FILE 2>/dev/null)
    SYNC_WARN_COUNT=${SYNC_WARN_COUNT:-0} #value is zero if file does not exist or does not contain what we are expecting

    if [ $SYNC_WARN_COUNT -ge $SYNC_WARN_THRESHOLD ]; then
      # YES, lets force a sync job. Do not need to remove warning marker here as it is automatically removed when the sync job is run by this script
      echo "Number of warning(s) ($SYNC_WARN_COUNT) has reached/exceeded threshold ($SYNC_WARN_THRESHOLD). Forcing a SYNC job to run. [`date`]"
      DO_SYNC=1
    else
      # NO, so let's increment the warning count and skip the sync job
      ((SYNC_WARN_COUNT += 1))
      echo $SYNC_WARN_COUNT > $SYNC_WARN_FILE
      echo "$((SYNC_WARN_THRESHOLD - SYNC_WARN_COUNT)) warning(s) till forced sync. NOT proceeding with SYNC job. [`date`]"
      DO_SYNC=0
    fi
  else
    # NO, so let's skip SYNC
    echo "Forced sync is not enabled. Check $TMP_OUTPUT for details. NOT proceeding with SYNC job. [`date`]"
    DO_SYNC=0
  fi
}

function chk_zero(){
  echo "###SnapRAID TOUCH [`date`]"
  echo "Checking for zero sub-second files."
  TIMESTATUS=$($SNAPRAID_BIN status | grep 'You have [1-9][0-9]* files with zero sub-second timestamp\.' | sed 's/^You have/Found/g')
  if [ -n "$TIMESTATUS" ]; then
    echo "$TIMESTATUS"
    echo "Running TOUCH job to timestamp. [`date`]"
    $SNAPRAID_BIN touch
    close_output_and_wait
    output_to_file_screen
    echo "TOUCH finished [`date`]"
  else
    echo "No zero sub-second timestamp files found."
  fi
}

function service_array_setup() {
  if [ -z "$SERVICES" ]; then
    echo "Please configure serivces"
  else
    echo "Setting up service array"
    read -a service_array <<<$SERVICES
  fi
}

function stop_services(){
  for i in ${service_array[@]}; do
    echo "Pausing Service - ""${i^}";
    docker pause $i
  done
}

function restore_services(){
  for i in ${service_array[@]}; do
    echo "Unpausing Service - ""${i^}";
    docker unpause $i
  done

  if [ $GRACEFUL -eq 1 ]; then
    return
  fi

  clean_desc

  exit
}

function clean_desc(){
  # Cleanup file descriptors
  exec 1>&{out} 2>&{err}

  # If interactive shell restore output
  [[ $- == *i* ]] && exec &>/dev/tty
}

function prepare_mail() {
  if [ $CHK_FAIL -eq 1 ]; then
    if [ $DEL_COUNT -gt $DEL_THRESHOLD -a $DO_SYNC -eq 0 ]; then
      MSG="Deleted Files ($DEL_COUNT) / ($DEL_THRESHOLD) Violation"
    fi

    if [ $DEL_COUNT -gt $DEL_THRESHOLD -a $UPDATE_COUNT -gt $UP_THRESHOLD -a $DO_SYNC -eq 0 ]; then
      MSG="$MSG & "
    fi

    if [ $UPDATE_COUNT -gt $UP_THRESHOLD -a $DO_SYNC -eq 0 ]; then
      MSG="$MSG Changed Files ($UPDATE_COUNT) / ($UP_THRESHOLD) Violation"
    fi

    SUBJECT="[WARNING] $SYNC_WARN_COUNT - ($MSG) $EMAIL_SUBJECT_PREFIX"
  elif [ -z "${JOBS_DONE##*"SYNC"*}" -a -z "$(grep -w "SYNC_JOB-" $TMP_OUTPUT)" ]; then
    # Sync ran but did not complete successfully so lets warn the user
    SUBJECT="[WARNING] SYNC job ran but did not complete successfully $EMAIL_SUBJECT_PREFIX"
  elif [ -z "${JOBS_DONE##*"SCRUB"*}" -a -z "$(grep -w "SCRUB_JOB-" $TMP_OUTPUT)" ]; then
    # Scrub ran but did not complete successfully so lets warn the user
    SUBJECT="[WARNING] SCRUB job ran but did not complete successfully $EMAIL_SUBJECT_PREFIX"
  else
    SUBJECT="[COMPLETED] $JOBS_DONE Jobs $EMAIL_SUBJECT_PREFIX"
  fi
}

function send_mail(){
  # Format for markdown
  curl -s -X POST --data-urlencode "token=${ONE_TIME_TOKEN}" --data-urlencode "message=$(cat ${TMP_OUTPUT})"  $WEBHOOK_URL
}

#Due to how process substitution and newer bash versions work, this function stops the output stream which allows wait stops wait from hanging on the tee process.
#If we do not do this and use normal 'wait' the processes will wait forever as newer bash version will wait for the process substitution to finish.
#Probably not the best way of 'fixing' this issue. Someone with more knowledge can provide better insight.
function close_output_and_wait(){
  exec >&$out 2>&$err
  wait $(pgrep -P "$$")
}

# Redirects output to file and screen. Open a new tee process.
function output_to_file_screen(){
  # redirect all output to screen and file
  exec {out}>&1 {err}>&2
  # NOTE: Not preferred format but valid: exec &> >(tee -ia "${TMP_OUTPUT}" )
  exec > >(tee -a "${TMP_OUTPUT}") 2>&1
}

# Set TRAP
trap restore_services INT EXIT

main "$@"
