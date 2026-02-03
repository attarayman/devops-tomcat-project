# DevOps Project Setup Guide

Complete guide to set up the CI/CD pipeline with GitHub, Maven, Tomcat, Docker, and Jenkins.

## Prerequisites

### 1. Install Required Software

**Java 11:**
```bash
java -version
```

**Maven:**
```bash
mvn -version
```

**Docker:**
```bash
docker --version
docker-compose --version
```

**Git:**
```bash
git --version
```

## Step-by-Step Setup

### Step 1: Clone/Initialize Repository

```bash
cd "C:\Users\320304832\Desktop\Ayman DevOps\Projects\devops-tomcat-project"
git init
git add .
git commit -m "Initial commit - DevOps Tomcat Application"
```

### Step 2: Create GitHub Repository

1. Go to GitHub and create a new repository
2. Push your code:

```bash
git remote add origin https://github.com/YOUR_USERNAME/devops-tomcat-project.git
git branch -M main
git push -u origin main
```

### Step 3: Local Build & Test

```bash
# Build the application
mvn clean package

# Run tests
mvn test

# Build Docker image
docker build -t devops-app .

# Run Docker container
docker run -d -p 8080:8080 devops-app

# Or use Docker Compose
docker-compose up -d
```

### Step 4: Verify Application

Open browser and test:
- http://localhost:8080/
- http://localhost:8080/hello
- http://localhost:8080/health

### Step 5: Install Jenkins

**Option 1: Docker (Recommended)**
```bash
docker run -d -p 8081:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:lts
```

**Option 2: Download Jenkins**
- Download from https://www.jenkins.io/download/
- Install and start service

**Access Jenkins:**
- http://localhost:8081
- Get initial password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Step 6: Configure Jenkins

1. **Install Plugins:**
   - Dashboard → Manage Jenkins → Plugins
   - Install: Git, Maven, Docker, Docker Pipeline, Pipeline

2. **Configure Tools:**
   - Manage Jenkins → Tools
   - Add JDK 11
   - Add Maven 3.8.6
   - Add Docker

3. **Add Credentials:**
   - Manage Jenkins → Credentials
   - Add Tomcat credentials (username/password)
   - Add GitHub credentials (if private repo)

### Step 7: Create Jenkins Pipeline

1. **New Item** → Enter name → **Pipeline** → OK

2. **Pipeline Configuration:**
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** Your GitHub repo URL
   - **Credentials:** Select GitHub credentials
   - **Branch:** */main
   - **Script Path:** Jenkinsfile

3. Click **Save**

### Step 8: Configure Tomcat (If using standalone Tomcat)

**Edit `tomcat-users.xml`:**
```xml
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="admin" password="admin123" roles="manager-gui,manager-script"/>
</tomcat-users>
```

**Edit `context.xml` in manager app:**
```xml
<!-- Comment out the Valve to allow remote access -->
<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValves"
       allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
-->
```

### Step 9: Run the Pipeline

1. Go to your Jenkins job
2. Click **Build Now**
3. Monitor the build progress
4. Check Console Output for details

### Step 10: Verify Deployment

```bash
# Check running containers
docker ps

# Check application
curl http://localhost:8080/health

# Check logs
docker logs devops-tomcat-app
```

## Pipeline Stages Explained

1. **Checkout** - Pull latest code from GitHub
2. **Build** - Compile Java code with Maven
3. **Test** - Run unit tests
4. **Package** - Create WAR file
5. **Code Quality** - Static analysis
6. **Build Docker Image** - Create container image
7. **Security Scan** - Scan for vulnerabilities
8. **Deploy to Tomcat** - Deploy WAR to Tomcat
9. **Deploy Docker** - Run Docker container
10. **Health Check** - Verify deployment
11. **Smoke Tests** - Basic functionality tests

## Troubleshooting

**Build Fails:**
```bash
# Check Maven
mvn clean install -X

# Check Java version
java -version
```

**Docker Issues:**
```bash
# Check Docker
docker info

# Clean up
docker system prune -a
```

**Jenkins Connection:**
```bash
# Check Jenkins logs
docker logs jenkins

# Restart Jenkins
docker restart jenkins
```

## Next Steps

1. **Add SonarQube** for code quality
2. **Add Nexus/Artifactory** for artifact management
3. **Add Kubernetes** for orchestration
4. **Add Monitoring** (Prometheus/Grafana)
5. **Add ELK Stack** for logging
6. **Add Security Scanning** (OWASP, Trivy)

## Useful Commands

```bash
# Maven
mvn clean install
mvn test
mvn package

# Docker
docker build -t devops-app .
docker run -p 8080:8080 devops-app
docker-compose up -d
docker-compose down
docker logs devops-tomcat-app

# Git
git status
git add .
git commit -m "message"
git push origin main

# Tomcat Deploy
curl -T target/devops-app.war \
  "http://admin:admin123@localhost:8080/manager/text/deploy?path=/devops-app"
```

## Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Maven Guide](https://maven.apache.org/guides/)
- [Docker Documentation](https://docs.docker.com/)
- [Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
