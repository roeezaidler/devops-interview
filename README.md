# DevOps Interview — Kubernetes Troubleshooting & Python

## Scenario

You've just joined a team that's deploying a **BookShelf** application on a Kubernetes cluster. The app is a simple Node.js web service backed by a PostgreSQL database.

A previous engineer attempted to set up the environment but left things in a broken state. Your job is to **get the application fully running and accessible**.

## What You Have

- A Kubernetes cluster with `kubectl` access already configured
- This repository containing the application manifests and a Python task

## Repository Structure

```
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
├── networkpolicy.yaml              # Network policy for DB access
└── python/
    └── Tweets.json                 # Data file for the Python task
```

---

## Part 1 — Kubernetes Troubleshooting

### Application Details

- **BookShelf App**: A Node.js/Express application running on port **3000**
  - `GET /health` — Health check endpoint (returns DB connection status)
  - `GET /api/books` — List all books
  - `POST /api/books` — Add a new book (`{ "title": "...", "author": "..." }`)
- **Database**: PostgreSQL 15

### Your Tasks

#### 1. Investigate the Cluster
Before applying any manifests, check the state of the cluster. There may be cluster-level issues preventing workloads from running properly.

#### 2. Fix and Deploy the Manifests
The manifests in this repository contain errors. Find and fix them, then deploy the application. Apply them in a logical order:
1. Namespace
2. Secrets & ConfigMaps
3. Persistent storage
4. Database (StatefulSet + Service)
5. Application (Deployment + Service)
6. Network Policy

#### 3. Verify the Application
The application should be:
- Running with healthy pods (no CrashLoopBackOff, no Pending)
- Returning a healthy response on `/health`
- Able to read and write books via the API

To access the application from your browser, use `kubectl port-forward` with `--address 0.0.0.0` so it's accessible externally:

```bash
kubectl port-forward svc/bookshelf-app -n bookshelf 8080:80 --address 0.0.0.0
```

Then open `http://<your-machine-ip>:8080` in Chrome.

#### 4. Document Your Findings
Keep notes of what you found and fixed. Be prepared to explain your troubleshooting approach and reasoning.

### Bonus Tasks (if time permits)
- Set up a **HorizontalPodAutoscaler** for the BookShelf app
- Create a **CronJob** that periodically checks the app's health

### Tips
- `kubectl describe` and `kubectl logs` are your best friends
- Check events: `kubectl get events -n bookshelf --sort-by='.lastTimestamp'`
- Think about what order things need to work in (cluster → storage → database → app)

---

## Part 2 — Python

This section tests your Python skills. It is not related to the Kubernetes section.

You can find a file named `Tweets.json` under the `python/` folder. This file is a simple JSON file that contains different tweets from several usernames from different times.

Write a Python script that implements the following **2 functions**:

### `mostLikableTweet`
A function that finds what tweet is the most likable one. The function should print:
- The content of the tweet
- The username
- The number of likes

### `mostLikesPerUser`
A function that finds what username has the most **total** likes (sum of all their tweets). The function should print:
- The username
- The total likes they received

You can run your script with:
```bash
python3 your_script.py
```

---

Good luck!
