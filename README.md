# Getting Started Locally

- Install Postgres
- Install Redis (for jobs)
- Install Mongo (for logging)
- Create the DB
  - rake db:create
  - rake db:migrate


# Get your AWS creds

Amazon RDS postgres database works wonders. You can create a Redis DB too on AWS (although there are plenty of free options, which are sufficient for getting started).

You'll need either a Bitbucket API key or a Github API key in order to deploy your code. This is so that you can log in and access your repos and set up web hooks and deploy keys to download the code.

# Create secrets

When deploying locally you should use a secrets file.

vi secrets.env

```
export GSG_KEY_SECRET=gsg_secret_key
export BITBUCKET_APP_TOKEN=
export BITBUCKET_APP_SECRET=
export GITHUB_KEY=
export GITHUB_SECRET=
export REPO_KEY_SECRET=repo_key_secret
export CERT_KEY_SECRET=cert_key_secret
export ENV_KEY_SECRET=somekey
export POSTGRES_HOST=
export POSTGRES_PORT=5432
export POSTGRES_PASS=
export POSTGRES_USERNAME=
export AWS_SECRET_ACCESS_KEY=
export AWS_ACCESS_KEY_ID=
export DEVISE_SECRET_KEY=devise_key_secret
```

Generate keys for REPO_KEY_SECRET, CERT_KEY_SECRET, GSG_KEY_SECRET, ENV_KEY_SECRET, and DEVISE_SECRET_KEY.

The other keys will need to come from the relevant services.


============

This codebase is a good example of how to prepare your codebase for deployment. You 
need a Dockerfile for each service in a pod and a docker-compose file for each pod. 
You can have multiple pods in a deployment, each defined by a docker-compose file. 
In fact to get started it can be informative to use this app to deploy itself. 
