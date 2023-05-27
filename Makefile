create-all:	create-cluster install-argocd install-argo-apps

create-cluster:
	kind create cluster --config ./local/cluster-config.yaml

install-argocd:
	kubectl create namespace argocd
	kubectl apply -f ./local/main-key.yaml
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm install argocd argo/argo-cd --wait -f ./local/argocd_values.yaml -n argocd

install-argo-apps:
	helm install argocd-setup ./setup/argocd/argo_applications --set environment=local

delete-cluster:
	kind delete cluster --name local-kafka-kubernetes

create-prod-cluster:
	aws configure
	terraform -chdir=./setup init
	terraform -chdir=./setup apply

clean-terraform-files:
	rm -rf ./setup/.terraform ./setup/.terraform.* ./setup/terraform.tfstate
	