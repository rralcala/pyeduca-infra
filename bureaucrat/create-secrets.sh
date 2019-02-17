#!/bin/sh

kubectl create secret generic signing-keys --from-file=developer.private --from-file=developer.public --from-file=lease.private --from-file=lease.public
