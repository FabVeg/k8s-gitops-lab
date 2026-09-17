
#!/bin/bash

echo "================================"
echo " Kubernetes Cluster Status"
echo "================================"

echo
echo "=== Nodes ==="
kubectl get nodes

echo
echo "=== Application Pods ==="
kubectl get pods

echo
echo "=== Application Services ==="
kubectl get services

echo
echo "=== Monitoring Pods ==="
kubectl get pods -n monitoring

echo
echo "=== Monitoring Services ==="
kubectl get services -n monitoring
