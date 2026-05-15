variable "minikube_cpus" {
  description = "Number of CPUs to allocate to the minikube node"
  type        = number
  default     = 2
}

variable "minikube_memory" {
  description = "Memory to allocate to the minikube node"
  type        = string
  default     = "4096mb"
}

variable "minikube_driver" {
  description = "Driver to use for minikube (docker, hyperkit, virtualbox)"
  type        = string
  default     = "docker"
}

variable "kubernetes_version" {
  description = "Kubernetes version passed to minikube start."
  type        = string
  default     = "v1.35.1"
}

variable "manifests_path" {
  description = "Relative path from the terraform directory to the k8s manifests directory"
  type        = string
  default     = "../k8s"
}
