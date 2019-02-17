#!/bin/sh
kubectl delete secret/yaas-config
kubectl create secret generic yaas-config --from-file=database.yml --from-file=password_salt --from-file=secret-token
