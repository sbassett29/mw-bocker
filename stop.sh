#/usr/bin/env bash
################################################################################
# Author: sbassett@wikimedia.org
# License: Apache 2 <https://opensource.org/licenses/Apache-2.0>
# Usage:
#   Stops a running php -S server (kills process)
#     (php.net/manual/en/features.commandline.webserver.php)
#   Env variables (see BOCK_env.sh):
#     BOCK_MW_SERVER    = default testmediawiki:8080 (don't use localhost)
#   (with set -u, script will exit if the above are not defined)
################################################################################
set -euo pipefail

# check binary dependencies
bins=("$BOCK_PHP" "kill" "pgrep")
for bin in "${bins[@]}"; do
    if [[ -z $(which $bin) ]]; then
        printf "dependency '$bin' does not appear to be installed - exiting.\n"
        exit 1
    fi  
done

# run php local server
php_s_pid=$(pgrep -f "php -S $BOCK_MW_SERVER" || true)
if [[ -n "$php_s_pid" ]]; then
    kill -9 "$php_s_pid"
fi
