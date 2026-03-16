# DevOps Interview — Kubernetes Troubleshooting

## Scenario

You've just joined a team that's deploying a **BookShelf** application on a Kubernetes cluster. The app is a simple Node.js web service backed by a PostgreSQL database.

A previous engineer attempted to set up the environment but left things in a broken state. Your job is to **get the application fully running and accessible**.

## What You Have

- A Kubernetes cluster with `kubectl` access already configured
- This repository containing the application manifests

## Repository Structure

```
manifests/
├── namespace.yaml                  # Namespace for all resources
├── postgres/
│   ├── secret.yaml                 # Database credentials
│   ├── pvc.yaml                    # Persistent storage for PostgreSQL
│   ├── statefulset.yaml            # PostgreSQL StatefulSet
│   └── service.yaml                # PostgreSQL headless service
├── bookshelf-app/
│   ├── configmap.yaml              # App configuration (DB connection, etc.)
│   ├── deployment.yaml             # App deployment
│   └── service.yaml                # App service (NodePort)
└── networkpolicy.yaml              # Network policy for DB access
```

## Application Details

- **BookShelf App**: A Node.js/Express application running on port **3000**
  - `GET /health` — Health check endpoint (returns DB connection status)
  - `GET /api/books` — List all books
  - `POST /api/books` — Add a new book (`{ "title": "...", "author": "..." }`)
- **Database**: PostgreSQL 15, running on the default port **5432**

## Your Tasks

### 1. Investigate the Cluster
Before applying any manifests, check the state of the cluster. There may be cluster-level issues preventing workloads from running properly.

### 2. Fix and Deploy the Manifests
The manifests in this repository contain errors. Find and fix them, then deploy the application. Apply them in a logical order:
1. Namespace
2. Secrets & ConfigMaps
3. Persistent storage
4. Database (StatefulSet + Service)
5. Application (Deployment + Service)
6. Network Policy

### 3. Verify the Application
The application should be:
- Running with healthy pods (no CrashLoopBackOff, no Pending)
- Accessible via NodePort **32400**
- Returning a healthy response on `/health`
- Able to read and write books via the API

### 4. Document Your Findings
Keep notes of what you found and fixed. Be prepared to explain your troubleshooting approach and reasoning.

## Bonus Tasks (if time permits)
- Set up a **HorizontalPodAutoscaler** for the BookShelf app
- Create a **CronJob** that periodically checks the app's health

## Tips
- `kubectl describe` and `kubectl logs` are your best friends
- Check events: `kubectl get events -n bookshelf --sort-by='.lastTimestamp'`
- Think about what order things need to work in (cluster → storage → database → app)

Good luck!
