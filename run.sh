#!/bin/bash

set -euo pipefail

readonly vnc_port=5900
readonly novnc_port=6080
readonly vnc_password="Test1234"

# Supported environment variables
#
# - urls              :: a list of Urls to load
# - rotate            :: enable tab rotation 1 or 0
# - rotate_delay_secs :: amount of time to display each tab
#

# TODO: URLs must contain the scheme right now, it's a limitation in
# the tab rotate plugin
urls=${urls:-http://google.com}
# Tab rotation is enabled by default, then the tab rotation plugin
# remove the --no-sandbox warning since it starts by closing all tabs
# and opening the configured ones
readonly rotate=1
rotate_delay_secs=${rotate_delay_secs:-86400}

script_home="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -d $script_home/chromium-run/ ]]
then
    cp -fr $script_home/chromium-run-prototype $script_home/chromium-run
fi

echo "starting chromium in docker, connect using novnc: http://localhost:$novnc_port?password=$vnc_password"

docker run --rm \
       --name chrome  \
       --shm-size=512m \
       -v $script_home/novnc:/usr/share/novnc \
       -v $script_home/chromium-run:/home/headless/.config \
       -p 5900:$vnc_port \
       -p 6080:$novnc_port \
       -e VNC_PW=$vnc_password \
       -e URL="${urls}" \
       -e VNC_COL_DEPTH=24 \
       -e ENABLE_TAB_ROTATE=$rotate \
       -e ROTATE_DELAY_SECS=$rotate_delay_secs \
       airtame/novnc-chromium
