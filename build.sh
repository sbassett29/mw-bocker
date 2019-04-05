#/usr/bin/env bash
################################################################################
# Author: sbassett@wikimedia.org
# License: Apache 2 <https://opensource.org/licenses/Apache-2.0>
# Usage:
#   Builds a local mediawiki developer enviroment in (hopefully) a simpler
#     and quicker way than the vagrant and docker environments do
#   Env variables (see BOCK_env.sh):
#     BOCK_MW_VER       = version of mediawiki to try to use
#                         - master = git clone from gerrit
#                         - not master (a ver num) = releases.wm.org
#     BOCK_MW_DIR       = /path/to/mediawiki install
#     BOCK_MW_REPO_URL  = repo for mw core (most likely gerrit.wm.org)
#     BOCK_MW_REL_URL   = releases base url
#     BOCK_MW_SERVER    = default testmediawiki:8080 (don't use localhost)
#     BOCK_PHP          = path to version of php to use
#   (with set -u, script will exit if the above are not defined)
################################################################################
set -euo pipefail

# check binary dependencies
bins=("$BOCK_PHP" "git" "curl" "tar" "printf" "composer" \
		"npm" "kill" "pgrep")
for bin in "${bins[@]}"; do
    if [[ -z $(which $bin) ]]; then
        printf "dependency '$bin' does not appear to be installed - exiting.\n"
        exit 1
    fi
done

# get and unpack mediawiki core - always a fresh install, for now
if [[ "$BOCK_MW_VER" = "master" ]]; then
	if [[ -d "$BOCK_MW_DIR" ]]; then
		rm -rf $BOCK_MW_DIR
	fi
	git clone --depth 1 -b $BOCK_MW_VER $BOCK_MW_REPO_URL $BOCK_MW_DIR \
	&& cd $BOCK_MW_DIR
else
	bock_mw_maj_ver=${BOCK_MW_VER%*.*}
	curl -fSL "${BOCK_MW_REL_URL}/${bock_mw_maj_ver}/mediawiki-${BOCK_MW_VER}.tar.gz" -o mw.tgz \
		&& rm -rf $BOCK_MW_DIR \
		&& mkdir $BOCK_MW_DIR \
		&& tar -xzf mw.tgz --strip-components=1 -C $BOCK_MW_DIR \
		&& rm -rf mw.tgz \
		&& cd $BOCK_MW_DIR
fi

# assume now in mw install dir, we should be
# composer && npm installs
composer install --no-plugins --no-scripts --no-suggest \
&& npm install --no-optional --no-shrinkwrap --no-bin-links --ignore-scripts

# install and configure skins/exts/services/etc.
# vector skin
cd skins \
&& git clone https://gerrit.wikimedia.org/r/mediawiki/skins/Vector \
&& git checkout $BOCK_MW_VER \
&& cd ..

# configure mediawiki
db_dir="$PWD/../data"
if [[ -d "$db_dir" ]]; then
	rm -rf $db_dir
fi
mkdir $db_dir

admin_user="admin"
admin_password="abc123abc123"
db="sqlite"
$BOCK_PHP maintenance/install.php \
--scriptpath="" \
--dbtype="$db" \
--dbpath="$db_dir" \
--dbname="testmediawiki" \
--dbserver="localhost" \
--lang="en" \
--pass="$admin_password" "Test Mediawiki" "$admin_user" --

echo ""
echo "Mediawiki installed!"
echo "Admin username: $admin_user"
echo "Admin password: $admin_password"
echo "Database: $db"
