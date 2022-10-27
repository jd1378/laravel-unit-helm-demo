- [Laravel Helm Demo](#laravel-helm-demo)
  - [Building Image](#building-image)
    - [Laravel + NGINX Unit](#laravel--nginx-unit)
    - [Workers](#workers)
    - [Installing Dependencies](#installing-dependencies)
    - [Deploy Script](#deploy-script)
  - [Deploying on Kubernetes](#deploying-on-kubernetes)
    - [Deploying Chart](#deploying-chart)
    - [Configuring Environment Variables](#configuring-environment-variables)
    - [Database](#database)
    - [Filesystems](#filesystems)
    - [Autoscaling](#autoscaling)
    - [Scaling Horizon](#scaling-horizon)

# Laravel Helm Demo

** DO NOT USE THIS, THIS IS NOT READY **

Run Laravel with nginx unit on Kubernetes using Helm. This project is horizontal scale-ready. forked from https://github.com/renoki-co/laravel-helm-demo , he has created the original charts, I just forked and edited for use with nginx unit, so most of the credit goes to him.

## Building Image

This project offers two alternative to build an image:

- for laravel + NGINX Unit projects (using `Dockerfile.unit`)
- for Workers (like CLI commands, using `Dockerfile.worker`)

images are based on my own [PHP Alpine](https://gitlab.com/jd1378/php-alpine) and [nginx-unit-alpine-php](https://gitlab.com/jd1378/nginx-unit-alpine-php) images.

### Laravel + NGINX Unit

The images generated with Laravel + NGINX Unit are using [jd1378/laravel chart](https://github.com/jd1378/laravel-helm-charts/tree/master/charts/laravel) and you may find there the documentation on how to deploy the chart.

Basically, the final Docker image will be built using the `Dockerfile.unit` file. It includes logs creation, permission changes and eventually clearing up additional files that you may not want to clutter your image with.

### Workers

The images generated for Workers are using [jd1378/laravel-worker chart](https://github.com/jd1378/laravel-helm-charts/tree/master/charts/laravel-worker) and you may find there the documentation on how to deploy the chart.

Workers need only the PHP CLI to be available.

### Installing Dependencies

It's recommended that the dependencies and other static data to be installed alongside with the container in CI/CD pipeline. This way, your pods will not take additional time each time they start to complete additional long steps like installing the dependencies or compiling the frontend assets.

In this demo project, in `.github/workflows/docker-release-tag.yml`, for example, the CI/CD pipeline will run additional steps like `composer install` and build the image. The final build will have dependencies already installed and you will be easily be implementing a fast-responding app, which is ready to scale really fast.

### Deploy Script

In the project root, you will find a `deploy.sh` file that will contains additional steps to run on each Pod startup. You might change it according to your needs, but keep in mind that it shouldn't take too much. The more it takes, the slower your scaling up will be.

In this file you may run additional steps that depend on your `.env` file, as at the Pod startup, the `.env` file is injected via the Secret kind.

Commands like `php artisan migrate` or `php artisan route:cache` are the most appropriate ones to run here.

## Deploying on Kubernetes

### Deploying Chart

A brief example can be found in `.helm/deploy.sh` on how to deploy a Laravel application. You will also find optional Helm releases that might help you deploying the application, such as Prometheus for PHP-FPM + NGINX scaling or NGINX Ingress Controller to port NGINX to the app service.

### Configuring Environment Variables

The nature of Laravel (as Deployment Kind) in Kubernetes is to be stateless. Meaning that the pods (holding the images built earlier) are created and destroyed without any persistence between roll-outs or roll-ins. To preserve this, the `.env` file is mounted as a `Secret` kind, and once the Pod creates, the contents of the secret is spilled out in the `.env` file within the pod.

These secrets can be encrypted at rest. For example, in AWS, you can specify [to encrypt Secret kinds with KMS](https://aws.amazon.com/about-aws/whats-new/2020/03/amazon-eks-adds-envelope-encryption-for-secrets-with-aws-kms/).

### Database

As explained earlier, because the nature of Laravel (or any other app as Deployment) in Kubernetes is to be stateless, you may want to persist data for your application using another service. You can use AWS RDS if you are in AWS, for example.

You can also deploy your databases, such as MySQL or PostgreSQL, such as [third party Helm Charts](https://bitnami.com/stack/mysql/helm).

### Filesystems

Using local storage will delete all your stored files between pod lifecycles. The best way is to use a third-party service, like AWS S3, Minio, Google Cloud Storage etc.

### Autoscaling

For better understading of autoscaling, Prometheus and Prometheus Adapter may be used to scrap data from nginx unit and laravel application to scale pods up or down based on the numbers.

### Scaling Horizon

It is well known that for Kubernetes, you may scale based on CPU or memory allocated to each pod. But you can also scale based on Prometheus metrics.

For ease of access, you may use the following exporters for your Laravel application:

- [Laravel Horizon Exporter](https://github.com/renoki-co/horizon-exporter) - used to scale application pods that run the queue workers
