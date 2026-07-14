#!/bin/bash
set -e
echo "=== Interview Environment Setup (EKS) ==="
echo ""

# --- Step 0: Delete bookshelf namespace if it exists ---
echo "[0/7] Deleting bookshelf namespace (if exists)..."
if kubectl get namespace bookshelf &>/dev/null; then
  kubectl delete namespace bookshelf --wait=true
  echo "  ✓ Namespace 'bookshelf' deleted"
else
  echo "  ⚠ Namespace 'bookshelf' does not exist — skipping"
fi

# --- Step 1: Taint all worker nodes ---
echo "[1/7] Tainting all worker nodes..."
WORKER_NODES=$(kubectl get nodes --selector='!node-role.kubernetes.io/control-plane,!node-role.kubernetes.io/master' -o jsonpath='{.items[*].metadata.name}')
if [ -z "$WORKER_NODES" ]; then
  # EKS nodes don't always have the control-plane label, get all nodes
  WORKER_NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')
fi
for NODE in $WORKER_NODES; do
  kubectl taint nodes "$NODE" dedicated=interviews:NoSchedule --overwrite
  echo "  ✓ Node '$NODE' tainted with dedicated=interviews:NoSchedule"
done

# --- Step 2: Cordon all worker nodes ---
echo "[2/7] Cordoning all worker nodes..."
for NODE in $WORKER_NODES; do
  kubectl cordon "$NODE"
  echo "  ✓ Node '$NODE' cordoned"
done

# --- Step 3: Scale CoreDNS to zero ---
echo "[3/7] Scaling CoreDNS to zero..."
COREDNS_DEPLOY=$(kubectl get deploy -n kube-system -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -i 'coredns' | head -1)
if [ -n "$COREDNS_DEPLOY" ]; then
  kubectl scale deployment "$COREDNS_DEPLOY" -n kube-system --replicas=0
  echo "  ✓ CoreDNS deployment '$COREDNS_DEPLOY' scaled to 0"
else
  echo "  ⚠ Could not find CoreDNS deployment — scale manually"
fi

# --- Step 4: Install Kyverno ---
echo "[4/7] Installing Kyverno..."
if kubectl get ns kyverno &>/dev/null; then
  echo "  ⚠ Kyverno namespace already exists — skipping install"
else
  helm repo add kyverno https://kyverno.github.io/kyverno/ 2>/dev/null || true
  helm repo update
  helm install kyverno kyverno/kyverno -n kyverno --create-namespace --wait --timeout 5m
  echo "  ✓ Kyverno installed"
fi

# --- Step 5: Apply bad Kyverno policy ---
echo "[5/7] Applying restrictive Kyverno policy..."
kubectl apply -f "$(dirname "$0")/kyverno-bad-policy.yaml"
echo "  ✓ Kyverno bad policy applied"

# --- Step 6: Create bookshelf namespace with restrictive LimitRange ---
echo "[6/7] Creating bookshelf namespace with restrictive LimitRange..."
kubectl create namespace bookshelf 2>/dev/null || true
kubectl apply -f "$(dirname "$0")/limitrange.yaml"
echo "  ✓ Namespace 'bookshelf' created with restrictive LimitRange"

# --- Step 7: Create interview-notes.txt ---
echo "[7/7] Creating interview-notes.txt..."
touch ~/interview-notes.txt
echo "  ✓ ~/interview-notes.txt created"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Setup Checklist:"
echo "  [✓] Namespace 'bookshelf' deleted (clean slate)"
echo "  [✓] All worker nodes tainted (dedicated=interviews:NoSchedule)"
echo "  [✓] All worker nodes cordoned"
echo "  [✓] CoreDNS scaled to 0 replicas"
echo "  [✓] Kyverno installed and bad policy applied"
echo "  [✓] Namespace 'bookshelf' created with restrictive LimitRange"
echo "  [ ] All broken manifests accessible to candidate (~/manifests/)"
echo "  [ ] Verify kubectl works from candidate machine"
echo "  [ ] Delete shell history: history -c && history -w"
echo "  [ ] Verify the candidate CANNOT access this setup document"
