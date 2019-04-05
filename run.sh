#/usr/bin/env bash
################################################################################
# Author: sbassett@wikimedia.org
# License: Apache 2 <https://opensource.org/licenses/Apache-2.0>
# Usage:
#   Runs a php app with php -S
#     (php.net/manual/en/features.commandline.webserver.php)
#   Env variables (see BOCK_env.sh):
#     BOCK_MW_DIR       = /path/to/mediawiki install
#     BOCK_MW_SERVER    = default testmediawiki:8080 (don't use localhost)
#     BOCK_PHP          = path to version of php to use
#     BOCK_TLS          = try to run over stunnel to simulate tls
#   (with set -u, script will exit if the above are not defined)
################################################################################
set -euo pipefail

# check binary dependencies
bins=("$BOCK_PHP" "printf" "kill" "pgrep" "stunnel")
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

cd $BOCK_MW_DIR \
&& $BOCK_PHP -S $BOCK_MW_SERVER

if [[ -n "$BOCK_TLS" ]]; then
	stunnel -d 443 -r 8080
fi
