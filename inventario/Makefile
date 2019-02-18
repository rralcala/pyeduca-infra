

.PHONY: inventario
inventario:
	kubectl delete secret/inventario-config
	kubectl create secret generic inventario-config --from-file=database.yml
	kubectl apply -f inventario.yaml
