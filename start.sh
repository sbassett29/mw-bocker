#/usr/bin/env bash
################################################################################
# Author: sbassett@wikimedia.org
# License: Apache 2 <https://opensource.org/licenses/Apache-2.0>
# Usage:
#   Starts a php app with php -S
#     (php.net/manual/en/features.commandline.webserver.php)
#   Env variables (see .env):
#     BOCKER_MW_DIR       = /path/to/mediawiki install
#     BOCKER_MW_SERVER    = default testmediawiki (don't use localhost)
#     BOCKER_MW_PORT      = php server port (8080) 
#     BOCKER_PHP          = path to version of php to use
#   (with set -u, script will exit if the above are not defined)
################################################################################
set -euo pipefail

# source .env
. .env

# check binary dependencies
bins=("$BOCKER_PHP" "printf" "kill" "pgrep" "stunnel")
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

cd $BOCKER_MW_DIR \
&& $BOCKER_PHP -S ${BOCKER_MW_SERVER}:${BOCKER_MW_PORT}
