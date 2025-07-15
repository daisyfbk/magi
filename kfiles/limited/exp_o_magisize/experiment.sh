#!/bin/bash

if [[ -z $REGISTRY_IP_DOMAIN ]]; then
    echo "The domain with its port of the registry is missing. E.g. registry.example.com:8080. Please add it to the variable \$REGISTRY_IP_DOMAIN."
    exit
fi

TIME_BETWEEN_DEPLOY_DELETE=${TIME_BETWEEN_DEPLOY_DELETE:-2}
TIME_BETWEEN_DIFFERENT_DEPLOYS=${TIME_BETWEEN_DIFFERENT_DEPLOYS:-60}

for j in $(seq 1 40); do
    i=$((40 - j + 1))
    echo "Applying $i"
    name="smallmb-$i-generated.yml"
cat << EOF > "$name"
apiVersion: v1
kind: Pod
metadata:
  name: smallmb-$i
  namespace: limited
spec:
  containers:
  - name: smallmb
    image: $REGISTRY_IP_DOMAIN/mfranzil/smallmb:$i
EOF
    kubectl apply -f "$name"
    sleep "$TIME_BETWEEN_DEPLOY_DELETE"
    kubectl delete -f "$name" --force --grace-period=0
    sleep $((TIME_BETWEEN_DIFFERENT_DEPLOYS + 2 * j))
done

kubectl -n limited run --image nginx:latest nginx
