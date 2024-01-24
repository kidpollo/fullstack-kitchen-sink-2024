# AWS Fullstack App Kitchen Sink 2024

This is a reference architecture for what I consider some best practices for a
Fullstack app based on my latest experiences.

This is built as a mono-repo that includes infrastructure, front-end, and
back-end. More details on that later. While mono-repos are excellent in some
situations, it does not mean this repo is intended to be cloned (but you could
:D) to start a new project. It references best practices around using Terraform,
an AWS Lambda-based backend, and a React Native frontend. However, it should be
a great starting point for a React Native-based app with a straightforward
request/response API using AWS lambda.

This repo also works as a helpful tech radar of software practices and libraries
that are relevant these days. I don't dislike frameworks. I think they can
provide great value at times. However, flexibility is critical for scaling and
evolving modern apps and infrastructures. Terraform and Terragrunt + the current
state of the Serverless capabilities provided by AWS, make for a highly
compelling combination that offers ultimate flexibility with some of the
niceties of frameworks without the bloat.

I realize a setup like this is not the most beginner-friendly as it would
require comfort level with tooling more familiar to infrastructure and DevOps
folks. However, I find that DevOps, infrastructure, and platform teams spend a
lot of their energy converting developer work to be compatible with
Gitops-compatible approaches, so why not embrace modern practices that
span teams from the start?

## Tools

### ASDF

Best tool manager! https://github.com/asdf-vm/asdf
This project uses `.tool-versions` to manage all the tools
required to build and run anything in this repo.

To install tools for this repo

```
asdf install
```

### AWS SSO-CLI

This mono repo assumes you have an AWS account. I prefer using
[aws-sso-cli](https://github.com/synfinatic/aws-sso-cli) to handle all my
aws-accounts.

Setup your profiles and set on your terminal session with:

```
aws-sso-profile Account:Role
```

However, the Terraform in this project does not need this, as it is configured to
use a profile that can automatically be set via `crential_process` in `~./aws/config`

```
...
[profile nonprod]
credential_process = /opt/homebrew/bin/aws-sso -u open -S "Default" process --arn arn:aws:iam::1234567:role/AdministratorAccess
...
```

## Infra

- Terragrunt to keep Terraform DRY.
- Fully immutable environments, easily configurable.
- Used to define infrastructure as well as package and deploy the backend.

Inspired by: https://github.com/gruntwork-io/terragrunt-infrastructure-live-example.

The infrastructure modules are also included in the mono-repo; however it is not
always ideal to have modules as part of a mono repo; see:
https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example?tab=readme-ov-file#disadvantages-of-a-monorepo-for-terraform-modules

The modules handle building, packaging, and deploying the backend to AWS. Having
these steps coupled as part of the Terraform code provides a less chaotic
approach to Gitops or CI/CD-based releases.

## Backend

## Todo API lambda handler (ts-lambda-handler)

Simple lambda handler for all endpoints of the Todo API. The API
endpoint should be available from the Terraform output. The Terragrunt apply
command builds and deploys the lambda automatically.

### Create Todo Item (POST /todo)

```bash
curl -X POST https://<api-endpoint>/todo \
     -H "Content-Type: application/json" \
     -d '{"todo": "Sample Todo Item", "completed": false}'
```

### Retrieve All Todo Items (GET /todo)

```bash
curl -X GET https://<api-endpoint>/todo
```

### Update Todo Item (PUT /todo/{id})

``` bash
curl -X PUT https://<api-endpoint>/todo/{id} \
     -H "Content-Type: application/json" \
     -d '{"todo": "Updated Todo Item Text", "completed": true}'
```

### Delete Todo Item (DELETE /todo/{id})

```bash
curl -X DELETE https://<api-endpoint>/todo/{id}
```

## Frontend

TODO

``` bash
bunx react-native@latest init TodoApp
# Disable hermes due to issues with krell https://reactnative.dev/docs/hermes#switching-back-to-javascriptcore
cd TodoApp
# setup krell
cat << EOF > deps.edn
{:deps
 {io.vouch/krell {:git/url "https://github.com/vouch-opensource/krell.git"
                  :sha "bdd627735e05d2afd08c3dfd5b3ea7d9be93554e"}
  com.pitch/uix.core {:mvn/version "1.0.1"}
  com.pitch/uix.dom {:mvn/version "1.0.1"}}}
EOF
cat << EOF > build.edn
{:main todo-app.core
 :output-to "target/main.js"
 :output-dir "target"}
EOF
mkdir -p src/todo_app
cat  << EOF > src/todo_app/core.cljs
(ns todo-app.core
  (:require [uix.core :refer [#_defui $]]
            #_[react-native :as rn]))

(defn ^:export -main
  "This is our react native app wrapper so we can have out context and business
  logic written in clojure"
  [& _args]
  ($ (.-default (js/require "../../App.tsx"))))
EOF
clj -M -m cljs.main --install-deps
rm package-lock.json

# run locally
bun install
bunx pod-install
clj -M -m krell.main -co build.edn -c -r # new terminal
bun start
bun ios # new terminal
```

