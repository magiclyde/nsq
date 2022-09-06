#!/bin/bash

for PROCESS in nsqlookupd nsqd nsqadmin; do
  pkill "$PROCESS"
done
