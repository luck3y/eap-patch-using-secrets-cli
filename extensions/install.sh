#!/usr/bin/env bash
# this will run at the end of the s2i build
set -x
echo "Running $PWD/install.sh"
injected_dir=$1
cp -rf ${injected_dir} $JBOSS_HOME/extensions
echo "Executing patch-build.cli"

$JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/extensions/patch-build.cli
