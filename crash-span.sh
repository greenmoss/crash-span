#!/usr/bin/env bash

## Have destination?
if [ "$#" -eq 0 ]
then
  echo "Usage: $@ <remote CrashPlan host> [<optional SSH arguments>]"
  exit 1
fi

## Supported platform?
if [[ "$OSTYPE" == "darwin"* ]]
then
  CONFIG_PATH='/Library/Application Support/CrashPlan'
  APP_PATH='/Applications/CrashPlan.app'
else
  echo "Your OS is not yet supported. Send a pull request please :)"
  exit 1
fi

## Have original config?
UI_PATH="$CONFIG_PATH/.ui_info"
if [ ! -s "$UI_PATH" ]
then
  echo "Missing original configuration file $UI_PATH; can not continue!"
  exit 1
fi

## Have new config?
NEW_UI="$CONFIG_PATH/ui_info.$1"
if [ ! -s "$NEW_UI" ]
then
  echo "You need to create your ui_info file:"
  echo $NEW_UI
  echo "(see README)"
  echo "exiting"
  exit 1
fi

## Already running app?
PS="ps -ef | grep CrashPlan | grep -v Service | grep -v 'menu bar' | grep '$APP_PATH' | grep -v grep"
eval $PS
if [ "$?" != "1" ]
then
  echo "Already running: $APP_PATH; exiting!"
  exit 1
fi

## Make sure we exit cleanly
function finish {
  CODE=$@
  echo # newline!

  ## Shut down the app IFF it's running
  if [ -n "$PS" ]
  then
    #sleep 2 # give it time to die naturally
    OUT=$(eval $PS | awk '{print $2}' | xargs)
    if [ "$OUT" != "" ]
    then
      echo "Exiting CrashPlan app pid(s): $OUT"
      for PID in $OUT
      do
        kill $PID
      done
    fi
  fi

  ## Shut down the tunnel
  if [ -n "$SSH_DEST" -a -n "$SSH_TUNNEL" ]
  then
    echo "Removing SSH tunnel"
    ps ax | grep [s]sh | grep $SSH_TUNNEL | grep $SSH_DEST | awk '{print $1}' | xargs kill
  fi

  ## Restore config
  if [ -n "$BACKUP_UI" -a -n "$UI_PATH" ]
  then
    echo -n 'mv '
    sudo mv -v "$BACKUP_UI" "$UI_PATH"
    if [ "$?" != "0" ]
    then
      echo "File restore from $BACKUP_UI failed! Check for $UI_PATH."
      CODE=$@
    fi
  fi

  exit $CODE
}
trap finish EXIT

## Back up config
BACKUP_UI="$CONFIG_PATH/ui_info.local"
echo -n 'mv '
sudo mv -v "$UI_PATH" "$BACKUP_UI"
if [ "$?" != "0" ]
then
  echo "File backup to $BACKUP_UI failed! Exiting."
  exit 1
fi

## Copy new config
echo -n 'cp '
sudo cp -v "$NEW_UI" "$UI_PATH"
if [ "$?" != "0" ]
then
  echo "Copying host configuration file $NEW_UI into place failed! Exiting."
  exit 1
fi

## Set up SSH tunnel
SSH_DEST="root@$1"
SSH_TUNNEL="4200:localhost:4243"
SSH_ARGS="-o ExitOnForwardFailure=yes -N -f -L $SSH_TUNNEL"
SSH_CMD="ssh $SSH_ARGS $SSH_DEST"
echo "Building SSH tunnel: '$SSH_CMD'"
$SSH_CMD
if [ "$?" != "0" ]
then
  echo "'$SSH_CMD' failed! Exiting."
  exit 1
fi

## Start CrashPlan
echo "Launching CrashPlan: $APP_PATH"
open -W $APP_PATH
if [ "$?" != "0" ]
then
  echo "starting '$APP_PATH' failed! Exiting."
  exit 1
fi
