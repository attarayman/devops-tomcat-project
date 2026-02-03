# DevOps Tomcat Project

A sample Java web application demonstrating complete CI/CD pipeline with GitHub, Maven, Tomcat, Docker, and Jenkins.

## Tech Stack
- **Java** 11
- **Maven** - Build automation
- **Tomcat** 9 - Application server
- **Docker** - Containerization
- **Jenkins** - CI/CD automation
- **GitHub** - Version control

## Project Structure
```
devops-tomcat-project/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/devops/app/
│       │       └── HelloServlet.java
│       └── webapp/
│           ├── WEB-INF/
│           │   └── web.xml
│           └── index.jsp
├── Dockerfile
├── Jenkinsfile
├── pom.xml
└── docker-compose.yml
```

## Local Development

### Build with Maven:
```bash
mvn clean package
```

### Deploy to Tomcat:
```bash
cp target/devops-app.war $TOMCAT_HOME/webapps/
```

### Run with Docker:
```bash
docker build -t devops-app .
docker run -p 8080:8080 devops-app
```

### Using Docker Compose:
```bash
docker-compose up -d
```

## CI/CD Pipeline

### Jenkins Pipeline Steps:
1. **Checkout** - Pull code from GitHub
2. **Build** - Maven clean package
3. **Test** - Run unit tests
4. **Docker Build** - Create Docker image
5. **Docker Push** - Push to registry (optional)
6. **Deploy** - Deploy to Tomcat/Docker

### Setup Jenkins:
1. Install plugins: Git, Maven, Docker, Pipeline
2. Create new Pipeline job
3. Point to GitHub repository
4. Use Jenkinsfile from repo

## Deployment Options

### Option 1: Direct Tomcat Deployment
```bash
curl -T target/devops-app.war \
  "http://admin:password@localhost:8080/manager/text/deploy?path=/devops-app"
```

### Option 2: Docker Deployment
```bash
docker-compose up -d
```

### Option 3: Kubernetes (Advanced)
```bash
kubectl apply -f k8s/deployment.yml
```

## Endpoints
- **Home**: http://localhost:8080/devops-app/
- **API**: http://localhost:8080/devops-app/hello
- **Health**: http://localhost:8080/devops-app/health

## Environment Variables
- `TOMCAT_USER` - Tomcat manager username
- `TOMCAT_PASSWORD` - Tomcat manager password
- `DOCKER_REGISTRY` - Docker registry URL (optional)

## Author
DevOps Learning Project
