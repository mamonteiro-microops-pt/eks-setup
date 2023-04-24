# terraform-test
aws eks --region us-east-1 update-kubeconfig --name eks-kafka-cluster

# Argocd
kubectl get svc -n argocd 

# eks-csi-driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.17" 

# clean
rm .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup 

# Local
ArgoCD Link

https://localhost:30080/

username:admin
password:password