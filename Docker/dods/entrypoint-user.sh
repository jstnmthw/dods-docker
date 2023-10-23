#!/bin/bash

exit_handler_user() {
  # Execute the shutdown commands
  echo -e "Stopping ${GAMESERVER}"
  ./"${GAMESERVER}" stop
  exitcode=$?
  exit ${exitcode}
}

# Exit trap
echo -e "Loading exit handler"
trap exit_handler_user SIGQUIT SIGINT SIGTERM

# Setup game server
if [ ! -f "${GAMESERVER}" ]; then
  echo -e ""
  echo -e "Creating ${GAMESERVER}"
  echo -e "================================="
  ./linuxgsm.sh "${GAMESERVER}"
fi

# Clear modules directory if not master
if [ "${LGSM_GITHUBBRANCH}" != "master" ]; then
  echo -e "not master branch, clearing modules directory"
  rm -rf /app/lgsm/modules/*
  ./"${GAMESERVER}" update-lgsm
elif [ -d "/app/lgsm/modules" ]; then
  echo -e "ensure all modules are executable"
  chmod +x /app/lgsm/modules/*
fi

# Install game server
if [ -z "$(ls -A -- "/data/serverfiles" 2> /dev/null)" ]; then
  echo -e ""
  echo -e "Installing ${GAMESERVER}"
  echo -e "================================="
  ./"${GAMESERVER}" auto-install
  install=1
else
  echo -e ""
  # Sponsor to display LinuxGSM logo
  #./"${GAMESERVER}" sponsor
fi

# Start update checks
echo -e ""
echo -e "Starting Update Checks"
echo -e "================================="
nohup watch -n "${UPDATE_CHECK}" ./"${GAMESERVER}" update > /dev/null 2>&1 &
minutes=$((UPDATE_CHECK / 60))
echo -e "update will check every ${minutes} minutes"

# Update game server
if [ -z "${install}" ]; then
  echo -e ""
  echo -e "Checking for Update ${GAMESERVER}"
  echo -e "================================="
  ./"${GAMESERVER}" update
fi

# Install Mods
if [ -z "$(ls -A -- "/data/serverfiles/${FOLDERNAME}/addons" 2> /dev/null)" ]; then
  echo -e ""
  echo -e "Installing Mods"
  echo -e "================================="
  mods_file="/app/install-mods.txt"
  if [ -f "$mods_file" ] && [ -s "$mods_file" ]; then
    while IFS= read -r mod
    do
      echo -e "Installing ${mod}"
      ./mods-expect.sh "$mod"
    done < "$mods_file"
  else
    echo "The install-mods.txt file is empty or does not exist."
  fi
fi

# Install RCBot2
if [ -z "$(ls -A -- "/data/serverfiles/${FOLDERNAME}/addons/rcbot2" 2> /dev/null)" ]; then
  echo -e ""
  echo -e "Installing RCBot2"
  echo -e "================================="
  wget $(curl -s https://api.github.com/repos/APGRoboCop/rcbot2/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) &&
  unzip rcbot2.zip -d "/data/serverfiles/${FOLDERNAME}" &&
  rm rcbot2.zip
fi

# Install gameMe
if [ ! -e "/data/serverfiles/${FOLDERNAME}/addons/sourcemod/gameme.smx" ]; then
  echo -e ""
  echo -e "Installing gameMe"
  echo -e "================================="
  wget https://www.gameme.com/downloads/gameme_plugin_sourcemod_v4.8.zip --no-check-certificate &&
  unzip gameme_plugin_sourcemod_v4.8.zip -d "/data/serverfiles/${FOLDERNAME}/addons/sourcemod" &&
  rm gameme_plugin_sourcemod_v4.8.zip
fi

# Download remote cfg files
if [ "${install}" == 1 ]; then
  ./install-config.sh
fi

# Start game server
echo -e ""
echo -e "Starting ${GAMESERVER}"
echo -e "================================="
./"${GAMESERVER}" start
sleep 5

# Display details
./"${GAMESERVER}" details
sleep 2
echo -e "Tail log files"
echo -e "================================="
tail -F "${LGSM_LOGDIR}"/*/*.log &
wait
