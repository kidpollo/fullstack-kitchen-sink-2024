# AWS Fullstack App Kitchen Sink Repo 2024

This repo contains a reference architecture of what I consider to be some best
practices for a Fullstack app based on my latest experiences.

This mono-repo includes infrastructure, front-end, and back-end. Mono-repos are
great for apps and services that are best released in lock-step, among many
other [benefits and drawbacks](https://medium.com/@alessandro.traversi/monorepos-advantages-and-disadvantages-233c1b7146c2).

It references best practices around using Terraform, an AWS Lambda-based
backend, and a React Native frontend. However, it should be a great starting
point for a React Native-based app with a straightforward request/response API
using AWS lambda.

This repo also works as a helpful tech radar of software practices and libraries
that are relevant these days. I don't dislike frameworks. I think they can
provide great value at times. However, flexibility is critical for scaling and
evolving modern apps and infrastructures. Terraform and Terragrunt + the current
state of the Serverless capabilities provided by AWS, make for a highly
compelling combination that offers ultimate flexibility with some of the
offerings of frameworks without the bloat.

I realize a setup like this is not the most beginner-friendly as it would
require comfort level with tooling more familiar to infrastructure and DevOps
folks. However, I find that DevOps, infrastructure, and platform teams spend a
lot of their energy converting developer work to be compatible with
Gitops-compatible approaches, so why not embrace modern practices that
span teams from the start?

https://github.com/kidpollo/fullstack-kitchen-sink-2024/assets/8182/823217dd-96dc-4098-87ca-9bdfcf9ae2c3

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

We must travel to the target environment folder to deploy this infrastructure to
AWS and run the Terragrunt command. Assuming we have our `noprod` profile set,
everything should work. Everything in this repo should fit nicely in the free
tier. To use your own account, modify `account.hcl` with the account-id you want
to target. I recommend creating a sub-account and setting up
[SSO](https://medium.com/@pushkarjoshi0410/how-to-set-up-aws-cli-with-aws-single-sign-on-sso-acf4dd88e056)
for it. If you set up the profile like the above, the `aws-sso` tool will trigger the
auth flow automatically.

```bash
cd infra/live/nonprod/us-west-2/stage
terragrunt run-all apply
terragrunt run-all output
```

NOTE: Save the output so you can use the resulting API URL to configure the frontend

### Local infra

TODO

## Backend

### Streaming services

TODO

### Todo API lambda handler (ts-lambda-handler)

Modern apps still need "classic" APIs with request-response flows. Previously,
developers spent time and effort on frameworks dealing with orthogonal concerns
like routing and authentication. Building individual handlers for business logic
is a much more scaleable and efficient approach, leading to time spent on what
matters.

Here, we use a simple lambda handler for all endpoints of the Todo API. The API
endpoint should be made available by the Terraform output. The Terragrunt apply
command builds and deploys the lambda automatically, sets up the API Gateway,
and configures the routes described in our Terraform modules. There is no need
for any bloat from a framework; let infrastructure be infrastructure.

The backend has a simplified authentication mechanism. It just requires the
Authorization header to be set with a username. This is not a production-ready
authentication mechanism but good as a baseline for propper authentication. I
recommend using lambda authorizers. Another serverless feature that abstracts
and simplifies concerns that add bloat to frameworks.

### Create Todo Item (POST /todo)

```bash
curl -X POST https://<api-endpoint>/todo \
    -H "Authorization: Bearer your_username" \
    -H "Content-Type: application/json" \
    -d '{"todo": "Sample Todo Item", "completed": false}'
```

### Retrieve All Todo Items (GET /todo)

```bash
curl -X GET https://<api-endpoint>/todo \
    -H "Authorization: Bearer your_username"
```

### Update Todo Item (PUT /todo/{id})

``` bash
curl -X PUT https://<api-endpoint>/todo/{id} \
    -H "Authorization: Bearer your_username" \
    -H "Content-Type: application/json" \
    -d '{"todo": "Updated Todo Item Text", "completed": true}'
```

### Delete Todo Item (DELETE /todo/{id})

```bash
curl -X DELETE https://<api-endpoint>/todo/{id} \
    -H "Authorization: Bearer your_username"
```

## Frontend

Here, we'll have a straightforward, modern React Native application with
some Clojure spice! I love Clojure and Clojurescript. There was a time when
React was new and exciting, but the Clojurescript community realized there was a
lot to improve on the core concepts of React. Class components were cumbersome,
and state management was messy and too complex.
[Reagent](https://reagent-project.github.io/) and
[Re-frame](https://day8.github.io/re-frame/) were a breath of fresh air at that
time. Users love these projects. However, the onboarding process and the
cognitive load of learning Clojure for some front-end engineers led to moderate
adoption. I've seen organizations actively pull away from this as hiring and
community support are not as strong as with other Frontend Dev communities. 

With time, React has improved a lot; now, with
[Hooks](https://medium.com/@matthill8286/embracing-modern-react-a-beginners-guide-to-react-hooks-2349fde20ce0),
many of those original concerns addressed by the Clojurescript community are
covered. Clojurescript has enhanced with time a lot. All of the limitations of
it being tied to the JVM have been lifted, and many new projects and libraries
have emerged. One of my favorites is
[NBB](https://github.com/babashka/nbb)](https://github.com/babashka/nbb), which
allows me to write fast scripts using CLJS directly on the NodeJS VM.

Much to my surprise, I combined 2 of those newer projects to allow me to create
a modern React application where I can use Clojurescript for what it is good at.
Manipulating data and handling business logic with Clojure is a complete joy and
requires far less code than equivalent JS/TS code. This is where
[Krell](https://github.com/vouch-opensource/krell) and
[UIX](https://github.com/pitch-io/uix) come to the rescue.

Krell allows us to have Clojurescipt and JS/TS co-exist. I chose to do this by
adding a simple wrapper using UIX that enables me to have a React context
written in Clojurescript that handles the communication with the backend and the
business logic. I could expand on this much more, but I'll let you look at the
`src` folder on the Frontend app to see how simple the integration is. I think
the steps to get a setup similar to this one are not too complicated. I am sure
there could be some automation around this. See the configuration below:

### Setup

The following is all you need to get the Krell wrapper and start writing modern
React with UIX. These changes have already been applied in this repo.


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
```

### Local Run

Assuming you deployed the backend with the Terragrunt command above, copy
`.env.dev` to `.env` inside the `Todo` folder and set the `TODO_API_URL=` in the
file with the `api_gateway_invoke_url=` output from the `terragrunt run-alloutput`
command. (TODO: automate this step)

```bash
# run these two when deps change
bun install
bunx pod-install
# Day to day operation
clj -M -m krell.main -co build.edn -c -r # new terminal
bun start
bun ios # new terminal
```




