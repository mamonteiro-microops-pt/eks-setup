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

Argo uses bcrypt algorithm, you can generate password on this link
https://bcrypt-generator.com/

https://localhost:30080/

username:admin
password:password

# Useful kafka commands

## list principals
kafka-acls --list --bootstrap-server localhost:9092 zookeeper.connect=zookeeper.confluent.svc.cluster.local:2181

## list topics
kafka-topics --bootstrap-server localhost:9092 --list