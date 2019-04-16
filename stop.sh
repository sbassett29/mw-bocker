#/usr/bin/env bash
################################################################################
# Author: sbassett@wikimedia.org
# License: Apache 2 <https://opensource.org/licenses/Apache-2.0>
# Usage:
#   Stops a running php -S server (kills process)
#     (php.net/manual/en/features.commandline.webserver.php)
#   Env variables (see .env):
#     BOCKER_MW_SERVER    = default testmediawiki (don't use localhost)
#     BOCKER_MW_PORT      = php server port (8080)
#     BOCKER_PHP          = path to version of php to use
#   (with set -u, script will exit if the above are not defined)
################################################################################
set -euo pipefail

# check binary dependencies
bins=("$BOCKER_PHP" "kill" "pgrep")
for bin in "${bins[@]}"; do
    if [[ -z $(which $bin) ]]; then
        printf "dependency '$bin' does not appear to be installed - exiting.\n"
        exit 1
    fi  
done

# run php local server
php_s_pid=$(pgrep -f "php -S ${BOCKER_MW_SERVER}:${BOCKER_MW_PORT}" || true)
if [[ -n "$php_s_pid" ]]; then
    kill -9 "$php_s_pid"
fi
