# Download remote git repo config files
echo -e ""
echo -e "Downloading remote cfg files"
echo -e "================================="
curl -L \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer ${CONFIG_GITHUB_TOKEN}" \
-H "X-GitHub-Api-Version: 2022-11-28" \
https://api.github.com/repos/${CONFIG_GITHUB_USERNAME}/${CONFIG_GITHUB_REPO}/zipball/${CONFIG_GITHUB_BRANCH} > ${CONFIG_GITHUB_BRANCH}.zip

# Unzip and remove the zip file
rm -rf /app/cfg/*
unzip -o "${CONFIG_GITHUB_BRANCH}.zip" -d /app/cfg
rm "${CONFIG_GITHUB_BRANCH}.zip"

# Find the parent directory of the Git repo contents
parent_dir=$(find "/app/cfg" -mindepth 1 -maxdepth 1 -type d -name "${CONFIG_GITHUB_USERNAME}*")

# Use rsync to update the /data directory without deleting existing files
if [ -d "$parent_dir" ]; then
  rsync -av --exclude='.gitignore' "$parent_dir"/ /data/
else
  echo "The parent directory of the Git repo contents could not be found."
fi

# Remove the parent directory of the Git repo contents
rm -rf "$parent_dir"

echo -e ""
echo "Remote cfg files downloaded and copied to the correct location... OK"