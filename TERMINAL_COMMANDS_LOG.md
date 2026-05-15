# Terminal log

Rough copy-paste from my machine while I built the images, started Minikube, and applied manifests. Repo root at `cloudnative-implementation`. More narrative context is in [README.md](README.md).

## Commands

```bash
docker login -u zaidwasem

docker build -f server/Dockerfile --target release -t zaidwasem/go-to-do-api:latest ./server
docker push zaidwasem/go-to-do-api:latest

docker build -f client/Dockerfile --target release -t zaidwasem/go-to-do-frontend:latest ./client
docker push zaidwasem/go-to-do-frontend:latest

minikube start --driver=docker
minikube addons enable ingress

kubectl wait -n ingress-nginx --for=condition=ready pod \
  -l app.kubernetes.io/component=controller --timeout=180s

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ --recursive

cd terraform
terraform init
terraform plan
# terraform apply — when K8s version in variables.tf matches minikube
```

`namespace.yaml` first because a plain recursive apply hit `api/` before the namespace existed.

Screenshots:

![Docker Hub](readme-assets/dockerhub-image.png)

![kubectl apply](readme-assets/k8s-apply.png)

## Transcript

```
zaid@RE-MB-224 cloudnative-implementation % docker login -u zaidwasem

i Info → A Personal Access Token (PAT) can be used instead.
         To create a PAT, visit https://app.docker.com/settings
         
         
Password: 
Login Succeeded
zaid@RE-MB-224 cloudnative-implementation % docker build -f server/Dockerfile --target release -t zaidwasem/go-to-do-api:latest ./server
docker push zaidwasem/go-to-do-api:latest
[+] Building 2.5s (15/15) FINISHED                                                     docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                   0.0s
 => => transferring dockerfile: 588B                                                                   0.0s
 => WARN: FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 2)                         0.0s
 => WARN: FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 13)                        0.0s
 => [internal] load metadata for gcr.io/distroless/base-debian10:latest                                0.8s
 => [internal] load metadata for docker.io/library/golang:1.14.4-stretch                               2.4s
 => [auth] library/golang:pull token for registry-1.docker.io                                          0.0s
 => [internal] load .dockerignore                                                                      0.0s
 => => transferring context: 50B                                                                       0.0s
 => [build 1/6] FROM docker.io/library/golang:1.14.4-stretch@sha256:b3a108bb5755799ca09aa46ce665a5084  0.0s
 => => resolve docker.io/library/golang:1.14.4-stretch@sha256:b3a108bb5755799ca09aa46ce665a5084d546f4  0.0s
 => [release 1/2] FROM gcr.io/distroless/base-debian10:latest@sha256:101798a3b76599762d3528635113f046  0.0s
 => => resolve gcr.io/distroless/base-debian10:latest@sha256:101798a3b76599762d3528635113f0466dc9655e  0.0s
 => [internal] load build context                                                                      0.0s
 => => transferring context: 311B                                                                      0.0s
 => CACHED [build 2/6] WORKDIR /code                                                                   0.0s
 => CACHED [build 3/6] COPY go.mod go.sum ./                                                           0.0s
 => CACHED [build 4/6] RUN go mod download                                                             0.0s
 => CACHED [build 5/6] COPY . .                                                                        0.0s
 => CACHED [build 6/6] RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/bin/todo              0.0s
 => CACHED [release 2/2] COPY --from=build --chown=1001:0 /go/bin/todo /bin/todo                       0.0s
 => exporting to image                                                                                 0.0s
 => => exporting layers                                                                                0.0s
 => => exporting manifest sha256:8c82450c85fa3af1a9d589eeb499955fdbe8e2ebf7510b0b5f908b840fe07876      0.0s
 => => exporting config sha256:5757f22d265cd4196d88eb37264ab175a471acbe0d0709e59a55ec957f14fb1e        0.0s
 => => exporting attestation manifest sha256:d83f0f5bdbaefa7839f68ebc3b8cea5a5f4b8538c46359a0c3a38277  0.0s
 => => exporting manifest list sha256:66038c9fa257fddf337b86b7d157284125cb6cc7ad4f43a809760873cba1b24  0.0s
 => => naming to docker.io/zaidwasem/go-to-do-api:latest                                               0.0s
 => => unpacking to docker.io/zaidwasem/go-to-do-api:latest                                            0.0s

 2 warnings found (use docker --debug to expand):
 - FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 13)
 - FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 2)
The push refers to repository [docker.io/zaidwasem/go-to-do-api]
38a5795581cb: Pushed 
7d441aeb75fe: Pushed 
21d6a6c3921f: Pushed 
5fc029cb8bde: Pushed 
latest: digest: sha256:66038c9fa257fddf337b86b7d157284125cb6cc7ad4f43a809760873cba1b24b size: 855
zaid@RE-MB-224 cloudnative-implementation % docker build -f client/Dockerfile --target release -t zaidwasem/go-to-do-frontend:latest ./client
docker push zaidwasem/go-to-do-frontend:latest
[+] Building 1.6s (20/20) FINISHED                                                     docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                   0.0s
 => => transferring dockerfile: 727B                                                                   0.0s
 => WARN: FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 2)                         0.0s
 => WARN: FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 8)                         0.0s
 => WARN: FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 16)                        0.0s
 => [internal] load metadata for docker.io/abdennour/nginx-distroless-unprivileged:1.18                1.5s
 => [internal] load metadata for docker.io/library/node:14-alpine                                      1.5s
 => [auth] abdennour/nginx-distroless-unprivileged:pull token for registry-1.docker.io                 0.0s
 => [auth] library/node:pull token for registry-1.docker.io                                            0.0s
 => [internal] load .dockerignore                                                                      0.0s
 => => transferring context: 50B                                                                       0.0s
 => [internal] load build context                                                                      0.0s
 => => transferring context: 955B                                                                      0.0s
 => [immutable-dependencies 1/5] FROM docker.io/library/node:14-alpine@sha256:434215b487a329c9e867202  0.0s
 => => resolve docker.io/library/node:14-alpine@sha256:434215b487a329c9e867202ff89e704d3a75e554822e07  0.0s
 => [release 1/4] FROM docker.io/abdennour/nginx-distroless-unprivileged:1.18@sha256:6f166d4f6dc840b2  0.0s
 => => resolve docker.io/abdennour/nginx-distroless-unprivileged:1.18@sha256:6f166d4f6dc840b2ecb8a4c5  0.0s
 => CACHED [release 2/4] WORKDIR /opt/app                                                              0.0s
 => CACHED [immutable-dependencies 2/5] WORKDIR /code                                                  0.0s
 => CACHED [immutable-dependencies 3/5] RUN npm set progress=false && npm config set depth 0           0.0s
 => CACHED [immutable-dependencies 4/5] COPY package.json package-lock.json ./                         0.0s
 => CACHED [immutable-dependencies 5/5] RUN npm install                                                0.0s
 => CACHED [build 3/5] COPY --from=immutable-dependencies /code/node_modules ./node_modules            0.0s
 => CACHED [build 4/5] COPY . .                                                                        0.0s
 => CACHED [build 5/5] RUN npm run build                                                               0.0s
 => CACHED [release 3/4] COPY --from=build --chown=1001:0 /code/conf/nginx /etc/nginx/conf.d           0.0s
 => CACHED [release 4/4] COPY --from=build  --chown=1001:0 /code/build/. .                             0.0s
 => exporting to image                                                                                 0.0s
 => => exporting layers                                                                                0.0s
 => => exporting manifest sha256:88ee837e1b9d66ff3d55bba76c81056811d3fab3003434b8814cb629507914dc      0.0s
 => => exporting config sha256:7d33d222ab2a8756c525b260f79aa10436fab24b5aa67b6a52203aad7f030290        0.0s
 => => exporting attestation manifest sha256:ec4d8d547b4c51bc69469ececf0dba4ad2b1b79683756d4effae814c  0.0s
 => => exporting manifest list sha256:cf414e80ad5b8997530e1d1a674f14030c6af3a9aaa59e5fed153417d6ed57f  0.0s
 => => naming to docker.io/zaidwasem/go-to-do-frontend:latest                                          0.0s
 => => unpacking to docker.io/zaidwasem/go-to-do-frontend:latest                                       0.0s

 4 warnings found (use docker --debug to expand):
 - FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 8)
 - FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 16)
 - InvalidBaseImagePlatform: Base image abdennour/nginx-distroless-unprivileged:1.18 was pulled with platform "linux/amd64", expected "linux/arm64" for current build (line 16)
 - FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 2)
The push refers to repository [docker.io/zaidwasem/go-to-do-frontend]
cfea4c5cfb15: Pushed 
b9cd0ea6c874: Pushed 
2891dbd9f53e: Pushed 
08994998f37b: Pushed 
e2745900642c: Pushed 
3a5ccadde142: Pushed 
7f503f973e53: Pushed 
latest: digest: sha256:cf414e80ad5b8997530e1d1a674f14030c6af3a9aaa59e5fed153417d6ed57f4 size: 856
zaid@RE-MB-224 cloudnative-implementation % minikube start --driver=docker
minikube addons enable ingress
😄  minikube v1.38.1 on Darwin 26.2 (arm64)
✨  Using the docker driver based on existing profile
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.50 ...
🏃  Updating the running docker "minikube" container ...
🐳  Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
💡  ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
💡  After the addon is enabled, please run "minikube tunnel" and your ingress resources would be available at "127.0.0.1"
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.7
    ▪ Using image registry.k8s.io/ingress-nginx/controller:v1.14.3
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.7
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled
zaid@RE-MB-224 cloudnative-implementation % kubectl wait -n ingress-nginx --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=180s

pod/ingress-nginx-controller-596f8778bc-8z7jd condition met
zaid@RE-MB-224 cloudnative-implementation % kubectl apply -f k8s/namespace.yaml

namespace/todo created
zaid@RE-MB-224 cloudnative-implementation % kubectl apply -f k8s/ --recursive

deployment.apps/api created
ingress.networking.k8s.io/api-ingress created
secret/api-secret created
service/api created
deployment.apps/db created
persistentvolumeclaim/db-pvc created
secret/db-secret created
service/db created
deployment.apps/frontend created
ingress.networking.k8s.io/frontend-ingress created
secret/frontend-secret created
service/frontend created
namespace/todo unchanged
networkpolicy.networking.k8s.io/db-allow-api-only created
networkpolicy.networking.k8s.io/frontend-egress-restrict created
zaid@RE-MB-224 cloudnative-implementation %
```

A bit later, `kubectl get pods -n todo`:

```
zaid@RE-MB-224 cloudnative-implementation % kubectl get pods -n todo                 
NAME                        READY   STATUS             RESTARTS        AGE
api-67758b8f8c-t8bxj        0/1     Running            6 (3m2s ago)    8m32s
api-67758b8f8c-xk69c        0/1     CrashLoopBackOff   5 (2m42s ago)   8m32s
db-cd8b88b94-p2fzc          0/1     ImagePullBackOff   0               8m32s
frontend-6464fc47f4-8hlmq   1/1     Running            0               8m32s
frontend-6464fc47f4-b2t5d   1/1     Running            0               8m32s
zaid@RE-MB-224 cloudnative-implementation % 
```

`cd terraform`, then `terraform init` and `terraform plan`:

```
zaid@RE-MB-224 cloudnative-implementation % cd terraform 
zaid@RE-MB-224 terraform % terraform init

Initializing provider plugins found in the configuration...
- Finding hashicorp/local versions matching "~> 2.0"...
- Finding hashicorp/null versions matching "~> 3.0"...
- Installing hashicorp/local v2.9.0...
- Installed hashicorp/local v2.9.0 (signed by HashiCorp)
- Installing hashicorp/null v3.3.0...
- Installed hashicorp/null v3.3.0 (signed by HashiCorp)

Initializing the backend...


Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
zaid@RE-MB-224 terraform % terraform plan 

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.apply_manifests will be created
  + resource "null_resource" "apply_manifests" {
      + id = (known after apply)
    }

  # null_resource.enable_ingress will be created
  + resource "null_resource" "enable_ingress" {
      + id = (known after apply)
    }

  # null_resource.minikube_start will be created
  + resource "null_resource" "minikube_start" {
      + id = (known after apply)
    }

  # null_resource.print_hosts_instruction will be created
  + resource "null_resource" "print_hosts_instruction" {
      + id = (known after apply)
    }

  # null_resource.wait_ingress_ready will be created
  + resource "null_resource" "wait_ingress_ready" {
      + id = (known after apply)
    }

  # null_resource.wait_pods_ready will be created
  + resource "null_resource" "wait_pods_ready" {
      + id = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + application_urls = {
      + api      = "http://todo-api.local"
      + frontend = "http://todo.local"
    }
  + cluster_info     = "Run: minikube ip  -- to get the cluster IP"
  + hosts_entry      = "Run: echo \"$(minikube ip) todo.local todo-api.local\" | sudo tee -a /etc/hosts"
  + kubectl_commands = {
      + get_all      = "kubectl get all -n todo"
      + get_ingress  = "kubectl get ingress -n todo"
      + get_pods     = "kubectl get pods -n todo"
      + get_services = "kubectl get svc -n todo"
    }

──────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.
zaid@RE-MB-224 terraform % terraform apply


```

Docker nagged about lowercase `as` in the Dockerfiles. The frontend image also complained about amd64 vs my arm64 laptop; the cluster still pulled and ran it on my setup.
