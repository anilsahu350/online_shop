# Online Shop 🛍️ — DevOps & Kubernetes Deployment

Welcome! This repository contains the **Online Shop** project — a modern e-commerce web application deployed with a full DevOps pipeline and Kubernetes infrastructure. This branch (`feature/shopping-cart-devops`) highlights my hands-on experience in automating build, testing, containerization, and cloud deployment.

---

## Project Summary

The Online Shop is a React-based web application demonstrating:

- **CI/CD automation** using Jenkins pipelines  
- **Code quality & security scanning** with SonarQube, OWASP Dependency Check, and Trivy  
- **Containerization** using Docker with optimized multi-stage builds  
- **Kubernetes orchestration** for scalable, reliable deployments  
- **Ingress routing** for HTTP traffic management  
- **MySQL deployment** with persistent storage and secret management (for practice)  

---

## Key Features & Highlights

### Jenkins Pipeline

- Automatically builds, scans, and tests the project on every push  
- Performs SonarQube analysis for code quality  
- Runs OWASP Dependency Check and Trivy scans to identify vulnerabilities  
- Builds Docker images and pushes to Docker Hub securely  
- Sends detailed email reports with logs and scan summaries  

### Docker

- Multi-stage Dockerfile reduces image size by ~1GB and improves build times  
- `.dockerignore` excludes unnecessary files from the image  
- Docker Hub used as the image registry  

### Kubernetes Deployment

- Online Shop deployed as a Deployment with 2 replicas in the `online-shop-prod` namespace  
- Apache service deployed alongside, exposed via Kubernetes Service  
- Ingress resource routes `/shop` traffic to the app and `/apache` to the Apache service  
- MySQL deployed in a separate `mysql-ns` namespace with ConfigMaps and Secrets for secure environment setup and persistent volume claim for data storage  

---

## Architecture Overview

The architecture of this project is designed to demonstrate a robust, scalable, and secure deployment of a modern e-commerce application using DevOps and Kubernetes best practices:

- **Application Layer:**  
  React-based frontend hosted in Docker containers and orchestrated via Kubernetes. It handles product browsing, shopping cart, and checkout functionalities.

- **Backend Services:**  
  An Apache HTTP Server is deployed as a separate Kubernetes Deployment and Service for serving static content or proxying requests.

- **Database Layer:**  
  A MySQL database runs in its own namespace (`mysql-ns`) using PersistentVolumes for data and Kubernetes Secrets for sensitive credentials.

- **Containerization & Deployment:**  
  Optimized Docker multi-stage builds are used for container images. Jenkins automates CI/CD, including scanning, building, and deploying containers to the cluster.

- **Kubernetes Orchestration:**  
  Kubernetes ensures high availability with two replicas, manages networking, and scales services as needed.

- **Ingress & Networking:**  
  NGINX Ingress controller routes incoming traffic using clean, path-based rules:
  - `/shop` → Online Shop frontend  
  - `/apache` → Apache service  

- **Security & Quality:**  
  Continuous security and quality checks using SonarQube, OWASP Dependency Check, and Trivy ensure reliability and early detection of issues.

This modular architecture supports scalability, maintainability, and production-readiness in a cloud-native environment.

```plaintext
User --> Ingress Controller -->
         |--> Online Shop Service (Port 3000)
         |--> Apache Service (Port 80)

```
## Kubernetes Resources

```bash
├── apache-deployment.yml
├── apache-service.yml
├── deployment.yml
├── hpa.yml
├── ingress.yml
├── kind-cluster.yml
├── mysql
│   ├── configmap.yml
│   ├── deployment.yml
│   ├── namespace.yml
│   ├── persistentVolume.yml
│   ├── persistentVolumeClaim.yml
│   └── secrets.yml
├── namespace.yml
├── service.yml
└── vpa.yml
```


## How to Run / Test

1. Clone the repo and checkout branch `feature/shopping-cart-devops`
2. Run Jenkins pipeline for automated build and deployment
3. Access the deployed application via the configured Ingress URL (e.g., `http://yourdomain/shop`)
4. (Practice) MySQL deployed separately for learning persistent storage and secrets in Kubernetes

---

## Technologies Used

- React, JavaScript, CSS (Frontend)
- Jenkins (CI/CD)
- SonarQube, OWASP Dependency Check, Trivy (Security & Quality)
- Docker (Containerization)
- Kubernetes (Deployment & Orchestration)
- MySQL (Database)
- AWS EC2 (Cloud Hosting)

---

## Improvements & Future Work

- Integrate MySQL fully with the Online Shop backend
- Add automated testing & monitoring
- Enable Horizontal Pod Autoscaling (HPA) for scalability
- Migrate to managed Kubernetes (EKS/GKE/AKS) for production readiness

---

## Contact

If you'd like to know more about the project or my DevOps experience, feel free to reach out:

**Email:** anilsahu350@gmail.com  
**GitHub:** [https://github.com/anilsahu350](https://github.com/anilsahu350)

---

Thank you for reviewing my project!  
Happy to discuss any part of this setup..
