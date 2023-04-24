PASSWORD := "\$$2a\$$10\$$CAF82t.Bs.C030HGplOLZebyppdkBGliti03ZAKqmJJTh3Mf95cBq"

create-cluster:
	kind create cluster --config ./local/cluster-config.yaml

install-argocd:
	kubectl create namespace argocd
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm install argocd argo/argo-cd --wait --set server.service.type=NodePort --set configs.secret.argocdServerAdminPassword=$(PASSWORD) -n argocd

install-argo-apps:
	helm install argocd-setup ./eks-kafka/argocd/argo_applications

delete-cluster:
	kind delete cluster --name local-kafka-kubernetes