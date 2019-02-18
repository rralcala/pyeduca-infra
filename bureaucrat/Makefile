

.PHONY: bureaucrat
bureaucrat:
	kubectl delete secret/signing-keys
	kubectl create secret generic signing-keys --from-file=developer.private --from-file=developer.public --from-file=lease.private --from-file=lease.public
	kubectl apply -f bureaucrat.yamll
