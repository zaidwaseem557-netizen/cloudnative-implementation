terraform {
  required_version = ">= 1.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "null_resource" "minikube_start" {
  provisioner "local-exec" {
    command = "minikube start --driver=${var.minikube_driver} --cpus=${var.minikube_cpus} --memory=${var.minikube_memory} --kubernetes-version=${var.kubernetes_version}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube stop"
  }
}

resource "null_resource" "enable_ingress" {
  depends_on = [null_resource.minikube_start]

  provisioner "local-exec" {
    command = "minikube addons enable ingress"
  }
}

resource "null_resource" "wait_ingress_ready" {
  depends_on = [null_resource.enable_ingress]

  provisioner "local-exec" {
    command = "kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s"
  }
}

resource "null_resource" "apply_manifests" {
  depends_on = [null_resource.wait_ingress_ready]

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      kubectl apply -f "${path.module}/${var.manifests_path}/namespace.yaml"
      kubectl apply -f "${path.module}/${var.manifests_path}/" --recursive
EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete namespace todo --ignore-not-found=true"
  }
}

# Step 5: Wait for all application pods to be ready
resource "null_resource" "wait_pods_ready" {
  depends_on = [null_resource.apply_manifests]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for DB pod..."
      kubectl wait --namespace todo --for=condition=ready pod --selector=app=db --timeout=180s || true
      echo "Waiting for API pods..."
      kubectl wait --namespace todo --for=condition=ready pod --selector=app=api --timeout=180s
      echo "Waiting for Frontend pods..."
      kubectl wait --namespace todo --for=condition=ready pod --selector=app=frontend --timeout=180s
      echo "All pods are ready!"
      kubectl get pods -n todo
EOT
  }
}

# Step 6: Print /etc/hosts update instruction
resource "null_resource" "print_hosts_instruction" {
  depends_on = [null_resource.wait_pods_ready]

  provisioner "local-exec" {
    command = <<-EOT
      MINIKUBE_IP=$(minikube ip)
      echo ""
      echo "=========================================="
      echo "Deployment complete!"
      echo ""
      echo "Add the following to your /etc/hosts:"
      echo "$MINIKUBE_IP  todo.local  todo-api.local"
      echo ""
      echo "Then open http://todo.local in your browser"
      echo "=========================================="
EOT
  }
}
