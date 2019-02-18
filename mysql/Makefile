

.PHONY: mysql
mysql:
	kubectl delete secret/db-root-pass
	kubectl create secret generic db-root-pass  --from-file=./password.txt
	kubectl apply -f mysql-pvc.yaml
	kubectl apply -f mysql.yaml
