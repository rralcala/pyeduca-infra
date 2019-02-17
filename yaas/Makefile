

.PHONY: yaas-web
yaas-web:
	kubectl delete secret/yaas-config
	kubectl create secret generic yaas-config --from-file=database.yml --from-file=password_salt --from-file=secret-token
	kubectl apply -f yaas.yaml
