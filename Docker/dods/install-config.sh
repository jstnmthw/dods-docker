echo -e ""
  echo -e "Downloading remote cfg files"
  echo -e "================================="
  curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${CONFIG_GITHUB_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${CONFIG_GITHUB_USERNAME}/${CONFIG_GITHUB_REPO}/zipball/${CONFIG_GITHUB_BRANCH} > ${CONFIG_GITHUB_BRANCH}.zip

  unzip -o ${CONFIG_GITHUB_BRANCH}.zip -d /app/cfg
  rm ${CONFIG_GITHUB_BRANCH}.zip

  parent_dir=$(find "/app/cfg" -mindepth 1 -maxdepth 1 -type d -name "${CONFIG_GITHUB_USERNAME}*")
  mv "$parent_dir"/* "/app/cfg"
  rm -rf "$parent_dir"

  # Dynamically copy files to their correct locations
  for file in "/app/cfg"/*; do
    filename=$(basename "$file")
      echo "============== ${filename} ==============";
      case "$filename" in
        "server.cfg")
          echo -e "Copying ${filename} to /data/config-lgsm/${GAMESERVER}/${GAMESERVER}.cfg"
          cp "$file" "/data/config-lgsm/${GAMESERVER}/${GAMESERVER}.cfg"
        ;;
        "game.cfg")
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/cfg/${GAMESERVER}.cfg"
          cp "$file" "/data/serverfiles/${FOLDERNAME}/cfg/${GAMESERVER}.cfg"
        ;;
        "mapcycle.txt")
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/cfg/mapcycle.txt"
          cp "$file" "/data/serverfiles/${FOLDERNAME}/cfg/mapcycle.txt"
        ;;
        "rcbot2.cfg")
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/addons/rcbot2/rcbot2.cfg"
          cp "$file" "/data/serverfiles/${FOLDERNAME}/addons/rcbot2/rcbot2.cfg"
        ;;
        "admins.ini")
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/addons/sourcemod/configs/admins_simple.ini"
          cp "$file" "/data/serverfiles/${FOLDERNAME}/addons/sourcemod/configs/admins_simple.ini"
        ;;
        *)
        if [ -d "$file" ] && [ "$filename" = "profiles" ]; then
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/addons/rcbot2/profiles"
          cp -r "$file" "/data/serverfiles/${FOLDERNAME}/addons/rcbot2"
        fi
        if [ -d "$file" ] && [ "$filename" = "plugins" ]; then
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/addons/sourcemod/plugins"
          cp -r "$file" "/data/serverfiles/${FOLDERNAME}/addons/sourcemod"
        fi
        if [ -d "$file" ] && [ "$filename" = "materials" ]; then
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/materials"
          cp -r "$file" "/data/serverfiles/${FOLDERNAME}"
        fi
        if [ -d "$file" ] && [ "$filename" = "maps" ]; then
          echo -e "Copying ${filename} to /data/serverfiles/${FOLDERNAME}/maps"
          cp -r "$file" "/data/serverfiles/${FOLDERNAME}"
        fi
        ;;
      esac
  done
  echo -e ""
  echo "Remote cfg files downloaded and copied to the correct location... OK"