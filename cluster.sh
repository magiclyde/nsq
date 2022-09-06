#!/bin/bash
# note: start a little NSQ cluster with 2 nsqlookupd hosts, 5 nsqd nodes, and an instance of nsqadmin
# refer: https://anthonysterling.com/posts/quick-nsq-cluster.html

BASEDIR=.cluster
NSQLOOKUPD_LOG=$BASEDIR/log/nsqlookupd.log
NSQD_LOG=$BASEDIR/log/nsqd.log
NSQADMIN_LOG=$BASEDIR/log/nsqadmin.log
DATADIR=$BASEDIR/data
BLDDIR=build

for DIR in log data; do
  mkdir -p "$BASEDIR/$DIR"
done

if [ ! -d "$BLDDIR" ]; then
  make
fi

./cluster-stop.sh

for NODE in {1..2}; do
  $BLDDIR/nsqlookupd \
    -broadcast-address="nsqlookupd-0$NODE" \
    -tcp-address="127.0.0.1:410$NODE" \
    -http-address="127.0.0.1:411$NODE" >>"$NSQLOOKUPD_LOG" 2>&1 &
done

for NODE in {1..5}; do
  mkdir -p "$DATADIR/nsqd-$NODE"
  $BLDDIR/nsqd \
    -data-path="$DATADIR/nsqd-$NODE" \
    -broadcast-address="nsqd-0$NODE" \
    -tcp-address="127.0.0.1:412$NODE" \
    -http-address="127.0.0.1:413$NODE" \
    -lookupd-tcp-address="127.0.0.1:4101" \
    -lookupd-tcp-address="127.0.0.1:4102" >>"$NSQD_LOG" 2>&1 &
done

$BLDDIR/nsqadmin \
  -http-address="127.0.0.1:4141" \
  -lookupd-http-address="127.0.0.1:4111" \
  -lookupd-http-address="127.0.0.1:4112" >>"$NSQADMIN_LOG" 2>&1 &

netstat -nlpt | grep nsq | sort

