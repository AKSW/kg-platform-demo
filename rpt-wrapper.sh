#!/bin/sh

## This script enabled a number of add-opens that are required for
## SANSA/Spark as well as the Javascript support in Apache Jena

## Usage: ./rpt-wrapper.sh /path/to/rpt.jar [rpt arguments]

set -e

JAVA=${JAVA_HOME:+$JAVA_HOME/bin/}java

EXTRA_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED \
    --add-opens=java.base/java.lang.invoke=ALL-UNNAMED \
    --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
    --add-opens=java.base/java.io=ALL-UNNAMED \
    --add-opens=java.base/java.net=ALL-UNNAMED \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    --add-opens=java.base/java.util=ALL-UNNAMED \
    --add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
    --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
    --add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
    --add-opens=java.base/sun.nio.cs=ALL-UNNAMED \
    --add-opens=java.base/sun.security.action=ALL-UNNAMED \
    --add-opens=java.base/sun.util.calendar=ALL-UNNAMED \
    --add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED"

SCRIPTING_OPTS="-Djena:scripting=true -Dnashorn.args=--language=es6"

exec $JAVA $EXTRA_OPTS $SCRIPTING_OPTS $JAVA_OPTS -jar "$@"
