#!/bin/sh
kubectl create secret generic db-root-pass  --from-file=./password.txt
