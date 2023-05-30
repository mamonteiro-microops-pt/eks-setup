create-all:	create-cluster install-argocd install-argo-apps

create-cluster:
	kind create cluster --config ./local/cluster-config.yaml

install-argocd:
	kubectl create namespace argocd
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm install argocd argo/argo-cd --wait -f ./local/argocd_values.yaml -n argocd --version 5.34.6

install-argo-apps:
	helm install argocd-setup ./setup/argocd/argo_applications --set environment=local

delete-cluster:
	kind delete cluster --name local-kafka-kubernetes

create-prod-cluster: clean-terraform-files
	aws configure
	terraform -chdir=./setup init
	terraform -chdir=./setup apply

clean-terraform-files:
	rm -rf ./setup/.terraform ./setup/.terraform.tfstate.lock.info ./setup/terraform.tfstate
