# Kubernetes & GitOps Lab

Mini-projet DevOps réalisé sur un environnement Linux local afin de mettre en pratique Kubernetes, le RUN, l'observabilité, l'automatisation et la documentation d'exploitation.

## Objectif

Construire et exploiter une petite application web conteneurisée sur Kubernetes, puis reproduire un incident de production afin de pratiquer :

* le déploiement Kubernetes ;
* le diagnostic d'incidents ;
* la remise en service ;
* l'observabilité avec Prometheus et Grafana ;
* l'automatisation avec des scripts ;
* la documentation RUN ;
* la gestion de configuration avec Git.

## Architecture

```text
                    ┌─────────────────────┐
                    │        Git          │
                    │  Sources YAML       │
                    │  Scripts / Docs     │
                    └──────────┬──────────┘
                               │
                               │ kubectl apply
                               ▼
                    ┌─────────────────────┐
                    │     Kubernetes      │
                    │        k3s          │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
        ┌─────────────────┐       ┌─────────────────────┐
        │      Nginx      │       │      Monitoring     │
        │    Deployment   │       │                     │
        │                 │       │ Prometheus          │
        │  ┌───────────┐  │       │ Grafana             │
        │  │    Pod    │  │       │ kube-state-metrics  │
        │  └───────────┘  │       │ Node Exporter       │
        │  ┌───────────┐  │       └─────────────────────┘
        │  │    Pod    │  │
        │  └───────────┘  │
        └────────┬────────┘
                 │
                 ▼
            NodePort :30840
```

## Technologies

* Linux / Debian
* Docker
* Kubernetes
* k3s
* kubectl
* Helm
* Nginx
* Prometheus
* Grafana
* Git
* Bash

## Déploiement

Les manifests Kubernetes se trouvent dans :

```text
kubernetes/
├── deployment.yaml
└── service.yaml
```

Déploiement :

```bash
kubectl apply -f kubernetes/
```

Vérification :

```bash
kubectl get pods
kubectl get services
```

L'application est exposée avec un Service de type `NodePort`.

Test :

```bash
curl http://localhost:30840
```

## Incident RUN

Un incident a volontairement été introduit en utilisant une image inexistante :

```yaml
image: nginx:version-inexistante
```

Le résultat observé était :

```text
ErrImagePull
ImagePullBackOff
```

### Diagnostic

Les commandes utilisées :

```bash
kubectl get pods
kubectl describe pod <pod>
```

Les événements Kubernetes ont permis d'identifier l'origine du problème :

```text
Failed to pull image "nginx:version-inexistante"
```

### Correction

L'image a été restaurée vers :

```yaml
image: nginx:1.27
```

Puis le Deployment a été réappliqué :

```bash
kubectl apply -f kubernetes/deployment.yaml
```

Validation :

```bash
kubectl rollout status deployment/web
kubectl get pods
curl http://localhost:30840
```

Le service est alors redevenu opérationnel.

Le détail de la procédure se trouve dans :

```text
docs/runbook.md
```

## Observabilité

La stack `kube-prometheus-stack` a été déployée avec Helm.

Elle fournit notamment :

* Prometheus ;
* Grafana ;
* kube-state-metrics ;
* Node Exporter ;
* Alertmanager.

Vérification :

```bash
kubectl get pods -n monitoring
```

Grafana peut être exposé temporairement avec :

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Puis :

```text
http://localhost:3000
```

Un dashboard Kubernetes permet notamment de suivre :

* l'utilisation CPU ;
* l'utilisation mémoire ;
* les ressources par namespace ;
* le réseau ;
* les workloads Kubernetes.

## Automatisation

Le script :

```text
scripts/status.sh
```

permet d'obtenir rapidement l'état du cluster, des applications et de la stack de monitoring.

Exécution :

```bash
./scripts/status.sh
```

Il affiche notamment :

* l'état des nodes ;
* les Pods applicatifs ;
* les Services ;
* les Pods de monitoring ;
* les Services de monitoring.

## Documentation RUN

Le runbook contient la procédure de diagnostic et de résolution de l'incident `ErrImagePull`.

```text
docs/runbook.md
```

L'objectif est de disposer d'une procédure reproductible permettant de :

1. identifier le symptôme ;
2. collecter les informations ;
3. trouver la cause ;
4. appliquer la correction ;
5. vérifier le retour au fonctionnement normal.

## Approche GitOps

Les manifests Kubernetes sont versionnés dans Git et servent de référence pour l'état souhaité de l'application.

Le projet met ainsi en pratique plusieurs principes associés au GitOps :

* configuration déclarative ;
* versionnement Git ;
* traçabilité des changements ;
* reproductibilité ;
* séparation entre configuration et exécution.

À ce stade, le projet ne met pas encore en place de contrôleur GitOps tel qu'Argo CD ou Flux : le déploiement est effectué avec `kubectl`.

## Structure du projet

```text
k8s-gitops-lab/
├── kubernetes/
│   ├── deployment.yaml
│   └── service.yaml
├── scripts/
│   └── status.sh
├── docs/
│   └── runbook.md
├── images/
└── README.md
```

## Compétences mises en pratique

| Domaine        | Mise en pratique                             |
| -------------- | -------------------------------------------- |
| Linux          | Administration de l'environnement            |
| Kubernetes     | Deployment, Pods, Service, NodePort          |
| RUN            | Incident, diagnostic, correction, validation |
| Observabilité  | Prometheus, Grafana, métriques Kubernetes    |
| Automatisation | Script Bash de contrôle                      |
|Git	         | Versionnement et historique des changements  |
|Documentation	 | Runbook d'exploitation                       |
|Helm            | Installation de la stack de monitoring       |
|Troubleshooting | Analyse des Events Kubernetes                |

## Historique Git

Les premières étapes du projet sont versionnées dans Git :

41562a7 docs: add runbook and cluster status script
7fe0442 feat: deploy nginx on kubernetes

## Évolutions possibles

* Ajouter Argo CD pour mettre en place un workflow GitOps complet.
* Ajouter des règles d'alerte Prometheus.
* Ajouter des tests automatisés.
* Ajouter une pipeline CI.
* Ajouter des manifests pour plusieurs environnements.
* Ajouter de l'Infrastructure as Code avec Terraform.
* Ajouter une stratégie de déploiement et de rollback plus complète.
