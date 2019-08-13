#!/usr/bin/env bash
################################################################################
# Author: sbassett@wikimedia.org
# License: Apache 2 <https://opensource.org/licenses/Apache-2.0>
# Usage:
#   Builds a local mediawiki developer enviroment in (hopefully) a simpler
#     and quicker way than the vagrant and docker environments do
#   Env variables (see .env):
#     BOCKER_MW_VER       = version of mediawiki to try to use
#                         - master = git clone from gerrit
#                         - not master (a ver num) = releases.wm.org
#     BOCKER_MW_DIR       = /path/to/mediawiki install
#     BOCKER_MW_REPO_URL  = repo for mw core (most likely gerrit.wm.org)
#     BOCKER_MW_REL_URL   = releases base url
#     BOCKER_MW_SERVER    = default testmediawiki (don't use localhost)
#     BOCKER_MW_PORT      = default port (8080)
#     BOCKER_PHP          = path to version of php to use
#     BOCKER_MW_ADMIN     = mw admin username
#     BOCKER_MW_ADMIN_PW  = mw admin password
#     BOCKER_MW_DB        = database type (sqlite)
#     BOCKER_MW_DB_DIR    = database data directory ($PWD/data)
#     BOCKER_MW_NPM       = run npm i post install
#   (with set -u, script will exit if the above are not defined)
################################################################################
set -euo pipefail

# check binary dependencies
bins=("$BOCKER_PHP" "git" "curl" "tar" "printf" "composer" \
		"npm" "kill" "pgrep")
for bin in "${bins[@]}"; do
    if [[ -z $(which $bin) ]]; then
        printf "dependency '$bin' does not appear to be installed - exiting.\n"
        exit 1
    fi
done

# get and unpack mediawiki core - always a fresh install, for now
if [[ "$BOCKER_MW_VER" = "master" ]]; then
	if [[ -d "$BOCKER_MW_DIR" ]]; then
		rm -rf $BOCKER_MW_DIR
	fi
	git clone --depth 1 -b $BOCKER_MW_VER $BOCKER_MW_REPO_URL $BOCKER_MW_DIR \
	&& cd $BOCKER_MW_DIR
else
	bocker_mw_maj_ver=${BOCKER_MW_VER%*.*}
	curl -fSL "${BOCKER_MW_REL_URL}/${bocker_mw_maj_ver}/mediawiki-${BOCKER_MW_VER}.tar.gz" -o mw.tgz \
		&& rm -rf $BOCKER_MW_DIR \
		&& mkdir $BOCKER_MW_DIR \
		&& tar -xzf mw.tgz --strip-components=1 -C $BOCKER_MW_DIR \
		&& rm -rf mw.tgz \
		&& cd $BOCKER_MW_DIR
fi

# assume now in mw install dir, we should be
# composer && npm installs
composer clearcache && composer update --no-plugins --no-scripts --no-suggest

if [[ "$BOCKER_MW_NPM" = "true" ]]; then
	npm install --no-optional --no-shrinkwrap --no-bin-links --ignore-scripts
fi

# install and configure skins/exts/services/etc.
# vector skin - only for git repos (not tarballs)
if [[ "$BOCKER_MW_VER" = "master" ]]; then
	cd skins \
	&& git submodule add -f https://gerrit.wikimedia.org/r/mediawiki/skins/Vector \
	&& git checkout $BOCKER_MW_VER \
	&& cd ..
fi

# configure mediawiki
if [[ -d "$BOCKER_MW_DB_DIR" ]]; then
	rm -rf $BOCKER_MW_DB_DIR
fi
mkdir $BOCKER_MW_DB_DIR

admin_user="$BOCKER_MW_ADMIN"
admin_password="$BOCKER_MW_ADMIN_PW"
db="$BOCKER_MW_DB"
$BOCKER_PHP maintenance/install.php \
--scriptpath="" \
--dbtype="$BOCKER_MW_DB" \
--dbpath="$BOCKER_MW_DB_DIR" \
--dbname="$BOCKER_MW_SERVER" \
--dbserver="localhost" \
--lang="en" \
--pass="$BOCKER_MW_ADMIN_PW" "Test Mediawiki" "$BOCKER_MW_ADMIN" --

echo ""
echo "Mediawiki installed!"
echo "Admin username: $BOCKER_MW_ADMIN"
echo "Admin password: $BOCKER_MW_ADMIN_PW"
echo "Database: $BOCKER_MW_DB"
