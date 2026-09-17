# Runbook — Kubernetes : incident ErrImagePull

## 1. Symptôme

Un Pod de l'application `web` reste dans l'état :

```text
ErrImagePull
```

ou :

```text
ImagePullBackOff
```

L'application peut alors ne plus disposer du nombre de réplicas attendu.

## 2. Vérification

Vérifier l'état des Pods :

```bash
kubectl get pods
```

Identifier le Pod en erreur puis consulter ses événements :

```bash
kubectl describe pod <pod-name>
```

Consulter également les événements récents :

```bash
kubectl get events --sort-by=.lastTimestamp
```

## 3. Diagnostic

Dans le cas rencontré pendant ce labo, les événements indiquaient :

```text
Failed to pull image "nginx:version-inexistante"
```

puis :

```text
ErrImagePull
ImagePullBackOff
```

La cause était une référence d'image Docker inexistante.

## 4. Correction

Vérifier l'image définie dans le Deployment :

```bash
kubectl get deployment web -o yaml
```

Corriger la référence dans :

```text
kubernetes/deployment.yaml
```

Exemple :

```yaml
image: nginx:1.27
```

Puis appliquer la configuration :

```bash
kubectl apply -f kubernetes/deployment.yaml
```

## 5. Validation

Suivre le déploiement :

```bash
kubectl rollout status deployment/web
```

Vérifier les Pods :

```bash
kubectl get pods
```

Les Pods doivent être dans l'état :

```text
Running
```

Tester ensuite l'application :

```bash
curl http://localhost:30840
```

La réponse attendue est la page par défaut de Nginx.

## 6. Observabilité

Vérifier l'état de la stack de monitoring :

```bash
kubectl get pods -n monitoring
```

Les composants Prometheus et Grafana doivent être opérationnels.

Grafana est accessible localement via un port-forward :

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Le dashboard Kubernetes permet notamment de suivre :

* l'utilisation CPU ;
* l'utilisation mémoire ;
* les Pods ;
* le trafic réseau ;
* les ressources par namespace.

## 7. Commandes utiles

### État général

```bash
kubectl get nodes
kubectl get pods
kubectl get services
```

### Diagnostic d'un Pod

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Événements

```bash
kubectl get events --sort-by=.lastTimestamp
```

### Déploiement

```bash
kubectl rollout status deployment/web
kubectl rollout history deployment/web
```

### Monitoring

```bash
kubectl get pods -n monitoring
kubectl get services -n monitoring
```

## 8. Retour d'expérience

L'incident a permis de valider une procédure de diagnostic Kubernetes basée sur :

1. l'identification du Pod en erreur ;
2. l'analyse de son état ;
3. l'analyse des événements Kubernetes ;
4. l'identification de la cause ;
5. la correction de la configuration ;
6. le suivi du rollout ;
7. la validation fonctionnelle de l'application.

Cette procédure permet de distinguer rapidement un problème applicatif d'un problème de déploiement ou de récupération d'image.
