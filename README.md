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

cd /mnt/config

echo 'security.protocol=SASL_PLAINTEXT
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="kafka" password="kafka-secret";
sasl.mechanism=PLAIN' > kafka-config.properties

## list principals
kafka-acls --list --bootstrap-server localhost:9092 zookeeper.connect=zookeeper.confluent.svc.cluster.local:2181 --command-config kafka-config.properties

kafka-acls --bootstrap-server localhost:9092 zookeeper.connect=zookeeper.confluent.svc.cluster.local:2181 --add --allow-principal User:pricing --operation Read --topic kn.pricing.created.v1 --command-config kafka-config.properties --group '*'

## list topics
kafka-topics --bootstrap-server localhost:9092 --list --command-config kafka-config.properties

## create a consumer
kafka-console-consumer --bootstrap-server localhost:9092 --topic __consumer_offsets --from-beginning
kafka-console-consumer --bootstrap-server localhost:9092 --topic kn.pricing.created.v1 --from-beginning

kafka-console-consumer --bootstrap-server localhost:9092 --topic kn.pricing.created.v1 --from-beginning --consumer.config c3-config.properties

## Remove ACL
kafka-acls --bootstrap-server localhost:9092 --remove --allow-principal User:c3 --operation Read --topic kn.pricing.created.v1 --command-config kafka-config.properties

