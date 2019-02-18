

.PHONY: inventario
inventario:
	kubectl delete secret/inventario-config
	kubectl create secret generic inventario-config
	kubectl apply -f inventario.yaml
