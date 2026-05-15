output "cluster_info" {
  description = "Instructions to get minikube cluster details"
  value       = "Run: minikube ip  -- to get the cluster IP"
}

output "hosts_entry" {
  description = "Add this to /etc/hosts to access the application"
  value       = "Run: echo \"$(minikube ip) todo.local todo-api.local\" | sudo tee -a /etc/hosts"
}

output "application_urls" {
  description = "Application access URLs (after updating /etc/hosts)"
  value = {
    frontend = "http://todo.local"
    api      = "http://todo-api.local"
  }
}

output "kubectl_commands" {
  description = "Useful kubectl commands to check deployment status"
  value = {
    get_pods     = "kubectl get pods -n todo"
    get_services = "kubectl get svc -n todo"
    get_ingress  = "kubectl get ingress -n todo"
    get_all      = "kubectl get all -n todo"
  }
}
