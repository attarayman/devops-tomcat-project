# AWS EC2 Setup Guide for DevOps Tomcat Project
## Complete Step-by-Step Implementation with MobaXterm

---

## PART 1: AWS EC2 INSTANCE SETUP

### Step 1.1: Launch EC2 Instance

1. **Log into AWS Console** → Navigate to EC2 Dashboard

2. **Launch Instance** with these configurations:
   - **Name**: `devops-tomcat-jenkins-server`
   - **AMI**: Amazon Linux 2023 (Free tier eligible) - Recommended!
   - **Instance Type**: `t3.small` (2 vCPU, 2GB RAM)
     - ⚠️ **Important**: t3.micro (1GB RAM) is NOT sufficient - Jenkins will crash
     - We'll add 2GB swap memory to compensate for limited RAM
   - **Key Pair**: Create new or select existing (.pem file)
   - **Storage**: 20GB gp3

3. **Security Group Configuration** (Critical!):
   ```
   Inbound Rules:
   - SSH         TCP  22     Your IP    (For MobaXterm access)
   - HTTP        TCP  80     0.0.0.0/0  (Public web access)
   - Custom TCP  8080 0.0.0.0/0  (Tomcat/App)
   - Custom TCP  8081 0.0.0.0/0  (Jenkins)
   - Custom TCP  9000 0.0.0.0/0  (SonarQube - optional)
   ```

4. **Click Launch Instance** and download your `.pem` key file if new

---

### Step 1.2: Connect via MobaXterm

1. **Open MobaXterm** on your Windows machine

2. **Create New SSH Session**:
   - Click: `Session` → `SSH`
   - **Remote Host**: Your EC2 Public IP (from AWS console)
   - **Username**: `ec2-user` (for Amazon Linux)
   - **Port**: 22
   - **Advanced SSH Settings** → Use private key → Browse to your `.pem` file
   - Click OK

3. **Verify Connection**:
   ```bash
   whoami
   # Should output: ec2-user
   
   pwd
   # Should output: /home/ec2-user
   ```

---

## PART 2: INSTALL DEPENDENCIES ON EC2

### Step 2.1: Update System and Add Swap Memory (CRITICAL for t3.small)

```bash
# Update package lists (Amazon Linux uses yum/dnf)
sudo yum update -y

# Add 2GB swap memory to handle Jenkins + Docker on t3.small
# This is REQUIRED - without it, Jenkins may crash due to low memory
sudo dd if=/dev/zero of=/swapfile bs=128M count=16
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent (survives reboots)
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# Verify swap is active
free -h
# You should see 2GB in the Swap row

swapon --show
# Should show /swapfile with 2GB
```

### Step 2.2: Install Java 11

```bash
# Install Java Development Kit 11
sudo yum install java-11-amazon-corretto-devel -y

# Verify installation
java -version
javac -version

# Set JAVA_HOME environment variable
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Verify JAVA_HOME
echo $JAVA_HOME
```

### Step 2.4: Install Maven

```bash
# Install Maven
sudo yum install maven -y

# If maven not found in default repos, install manually:
# sudo wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
# sudo tar -xvf apache-maven-3.9.6-bin.tar.gz -C /opt
# sudo ln -s /opt/apache-maven-3.9.6 /opt/maven
# echo 'export M2_HOME=/opt/maven' >> ~/.bashrc
# echo 'export PATH=$M2_HOME/bin:$PATH' >> ~/.bashrc
# source ~/.bashrc

# Verify installation
mvn -version

# Should show Maven 3.x and Java 11
```

### Step 2.5: Install Git

```bash
# Install Git (usually pre-installed on Amazon Linux)
sudo yum install git -y

# Configure Git
git config --global user.name "attarayman"
git config --global user.email "attarayman2022@gmail.com"

# Verify
git --version
```

---

## PART 3: UNDERSTANDING & INSTALLING DOCKER

### 🎓 Docker Basics - What You'll Learn

**What is Docker?**
Docker packages your application and everything it needs (Java, Tomcat, libraries) into a "container" that runs anywhere - your laptop, EC2, or any server.

**Key Concepts:**

1. **Dockerfile** = Recipe/Instructions
   - Tells Docker how to build your application
   - Example: "Start with Tomcat, copy my WAR file, run it"

2. **Image** = Package/Template
   - Built from Dockerfile
   - Like a snapshot of your application
   - Can share with others

3. **Container** = Running Application
   - Created from an image
   - Isolated environment where your app runs
   - Can start/stop/restart easily

4. **Docker Compose** = Multi-Container Manager
   - Manages multiple containers
   - Defined in `docker-compose.yml`
   - Start everything with one command

**In This Project You'll Learn:**
- ✅ How to read and write a Dockerfile
- ✅ Build images from your Java application
- ✅ Run containers and check their status
- ✅ Use docker-compose for easy deployment
- ✅ View logs and troubleshoot containers
- ✅ Integrate Docker with Jenkins for automation

**Your Project's Docker Flow:**
```
Source Code (Java) 
    ↓
Maven builds → WAR file
    ↓
Dockerfile copies WAR → Docker Image
    ↓
Run Image → Container (running app on port 8080)
```

**Don't worry!** Each command is explained step-by-step below. By the end, you'll understand Docker completely.

---

### Step 3.1: Install Docker Engine

```bash
# Amazon Linux 2023 - Simple Docker installation
# Update system first
sudo yum update -y

# Install Docker
sudo yum install docker -y

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify Docker installation
sudo docker --version

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose
docker-compose --version
```

### Step 3.2: Configure Docker Permissions

```bash
# Add ec2-user to docker group (avoid sudo for docker commands)
sudo usermod -aG docker ec2-user

# Apply group changes (IMPORTANT: reconnect SSH or run newgrp)
newgrp docker

# Test Docker without sudo
docker run hello-world

# Check Docker service status
sudo systemctl status docker
```

---

## PART 4: DEPLOY YOUR APPLICATION

### Step 4.1: Clone Your Repository

**Option A: Via GitHub (Recommended)**
```bash
# Create project directory
mkdir -p ~/devops-projects
cd ~/devops-projects

# Clone your repository (create GitHub repo first if not done)
git clone https://github.com/YOUR_USERNAME/devops-tomcat-project.git
cd devops-tomcat-project
```

**Option B: Transfer from Windows using MobaXterm**
1. In MobaXterm, left sidebar shows SFTP file browser
2. Navigate to `/home/ec2-user/`
3. Drag and drop your project folder from Windows
4. Then `cd ~/devops-tomcat-project`

### Step 4.2: Build Application with Maven

```bash
# Navigate to project directory
cd ~/devops-projects/devops-tomcat-project

# Clean and build
mvn clean package

# Verify WAR file created
ls -lh target/
# Should see: devops-app.war
```

### Step 4.3: Test Docker Build (Understanding Each Command)

**Step 1: Look at your Dockerfile first**
```bash
# Let's see what the Dockerfile does
cat Dockerfile
```
This shows the instructions Docker will follow.

**Step 2: Build Docker image**
```bash
# Build image named "devops-app" with tag "v1" from current directory (.)
docker build -t devops-app:v1 .

# What happened?
# - Docker read your Dockerfile
# - Downloaded base Tomcat image
# - Copied your WAR file
# - Created a new image
```

**Step 3: Verify image created**
```bashEasier Way!)

**What is Docker Compose?**
Instead of typing long `docker run` commands, you define everything in `docker-compose.yml` file and manage with simple commands.

**Step 1: Look at your docker-compose.yml**
```bash
# See what's configured
cat docker-compose.yml
```

**What you'll see:**
- Service name: `devops-app`
- Build from Dockerfile in current directory
- Port mapping: 8080:8080
- Health check: automatically checks if app is running
- Network: creates isolated network for containers

**Step 2: Stop test container (if running)**
```bash
docker stop test-app
docker rm test-app
```

**Step 3: Start with Docker Compose**
```bash
# Start all services defined in docker-compose.yml
# -d = detached mode (background)
docker compose up -d

# What happened?
# - Read docker-compose.yml
# - Built image if needed
# - Created container with all settings
# - Started container
# - Set up network and health checks
```

**Step 4: Check status**
```bash
# See all compose services
docker compose ps

# See logs
docker compose logs

# Follow logs in real-time
docker compose logs -f
# (Press Ctrl+C to stop following)
```

**Docker Compose Commands You'll Use:**
```bash
# Start services
docker compose up -d

# Stop services (containers still exist)
docker compose stop

# Start stopped services
docker compose start

# Stop and remove containers
docker compose down

# Rebuild images and restart
docker compose up -d --build

# View logs
docker compose logs -f devops-app

# See running services
docker compose ps

# Execute command in service container
docker compose exec devops-app bash
```

**Why Docker Compose is Better:**
- ✅ One command to start/stop everything
- ✅ Configuration saved in file (reproducible)
- ✅ Easy to add more services (database, monitoring, etc.)
- ✅ Built-in networking between containers
- ✅ Health checks and restart policies

**Try this - Add a second service (Optional Learning):**
You could later add MySQL database to docker-compose.yml and both services would work together!hat happened?
# - Created new container from devops-app:v1 image
# - Started Tomcat inside container
# - Made it accessible on port 8080
```

**Explanation of flags:**
- `-d` = detached (runs in background)
- `-p 8080:8080` = port mapping (host:container)
- `--name test-app` = gives container a friendly name
- `devops-app:v1` = which image to use

**Step 5: Check if container is running**
```bash
# See all running containers
docker ps

# You should see:
# CONTAINER ID   IMAGE           STATUS        PORTS                    NAMES
# def456...      devops-app:v1   Up 1 minute   0.0.0.0:8080->8080/tcp   test-app
```

**Step 6: View container logs**
```bash
# See what's happening inside the container
docker logs test-app

# Follow logs in real-time (Ctrl+C to stop)
docker logs -f test-app
```

**Step 7: Test the application**
```bash
# Test from EC2 terminal
curl http://localhost:8080/

# Test from your browser
# http://YOUR_EC2_PUBLIC_IP:8080/
```

**Useful Docker commands to try:**
```bash
# See all containers (including stopped)
docker ps -a

# Stop container
docker stop test-app

# Start container again
docker start test-app

# Restart container
docker restart test-app

# Execute command inside running container
docker exec -it test-app bash
# (You're now inside the container! Type 'exit' to leave)

# View container resource usage
docker stats test-app

# Remove container (must be stopped first)
docker stop test-app
docker rm test-app
```

### Step 4.4: Use Docker Compose (Recommended)

```bash
# Stop test container
docker stop test-app
docker rm test-app

# Start with docker compose
docker compose up -d

# Check logs
docker compose logs -f

# Stop with
# docker compose down
```

---

## PART 5: INSTALL AND CONFIGURE JENKINS

### Step 5.1: Install Jenkins

```bash
# Add Jenkins repository for Amazon Linux
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins status
sudo systemctl status jenkins

# Jenkins runs on port 8080 by default, change to 8081 to avoid conflict
# Edit Jenkins configuration
sudo sed -i 's/JENKINS_PORT="8080"/JENKINS_PORT="8081"/g' /usr/lib/systemd/system/jenkins.service

# Reload systemd and restart Jenkins
sudo systemctl daemon-reload
sudo systemctl restart jenkins

# Wait 30 seconds for Jenkins to start
sleep 30
```

### Step 5.2: Initial Jenkins Setup

```bash
# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# Copy this password
```

1. **Open browser**: `http://YOUR_EC2_PUBLIC_IP:8081`
2. **Paste the password** from above
3. **Install suggested plugins** (wait 5-10 minutes)
4. **Create admin user**:
   - Username: admin
   - Password: (choose secure password)
   - Email: your email
5. **Jenkins URL**: Keep as is or set to your domain
6. **Start using Jenkins**

### Step 5.3: Install Required Jenkins Plugins

1. Go to: **Manage Jenkins** → **Manage Plugins**
2. Click **Available** tab and install:
   - Maven Integration
   - Git plugin (usually pre-installed)
   - Docker Pipeline
   - Docker plugin
   - GitHub Integration
   - Pipeline
   - Credentials Binding

3. **Restart Jenkins** after installation

### Step 5.4: Configure Jenkins Tools

1. **Configure Maven**:
   - Manage Jenkins → Global Tool Configuration
   - Scroll to **Maven** section
   - Click "Add Maven"
   - Name: `Maven 3.8.6`
   - Install automatically: ✓
   - Version: 3.8.6
   - Save

2. **Configure JDK**:
   - Same page, **JDK** section
   - Click "Add JDK"
   - Name: `JDK 11`
   - Uncheck "Install automatically"
   - JAVA_HOME: `/usr/lib/jvm/java-11-amazon-corretto`
   - Save

---

## PART 6: CREATE JENKINS PIPELINE

### Step 6.1: Create Credentials for GitHub

1. **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. **Add Credentials**:
   - Kind: Username with password
   - Username: Your GitHub username
   - Password: GitHub Personal Access Token (create at GitHub.com → Settings → Developer settings → Personal access tokens)
   - ID: `github-credentials`
   - Description: GitHub Access
   - Create

### Step 6.2: Create Pipeline Job

1. **New Item** from Jenkins dashboard
2. Enter name: `devops-tomcat-pipeline`
3. Select: **Pipeline**
4. Click OK

5. **Configure Pipeline**:
   - **General**: ✓ GitHub project
     - Project URL: `https://github.com/YOUR_USERNAME/devops-tomcat-project`
   
   - **Build Triggers**: ✓ GitHub hook trigger for GITScm polling (for auto-build)
   
   - **Pipeline**:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: `https://github.com/YOUR_USERNAME/devops-tomcat-project.git`
     - Credentials: Select `github-credentials`
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`
   
   - **Save**

### Step 6.3: Fix Jenkinsfile for Linux

Your Jenkinsfile uses `bat` commands (Windows). Update it for Linux:

```bash
cd ~/devops-projects/devops-tomcat-project
nano Jenkinsfile
```

Replace all `bat` with `sh`:
- `bat 'mvn clean compile'` → `sh 'mvn clean compile'`
- `bat 'mvn test'` → `sh 'mvn test'`
- And so on...

Then commit and push:
```bash
git add Jenkinsfile
git commit -m "Update Jenkinsfile for Linux"
git push origin main
```

---

## PART 7: RUN THE COMPLETE CI/CD PIPELINE

### Step 7.1: Trigger Build

1. In Jenkins, click on `devops-tomcat-pipeline`
2. Click **Build Now**
3. Watch the **Console Output** (click on build #1)

### Step 7.2: Monitor Progress

Watch stages complete:
- ✅ Checkout
- ✅ Build
- ✅ Test
- ✅ Package
- ✅ Build Docker Image
- ✅ Deploy

### Step 7.3: Verify Deployment

```bash
# Check Docker containers
docker ps

# Should see your application running

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/hello
curl http://localhost:8080/health
```

**From your browser:**
- Application: `http://YOUR_EC2_PUBLIC_IP:8080/`
- Jenkins: `http://YOUR_EC2_PUBLIC_IP:8081/`

---

## TROUBLESHOOTING COMMON ISSUES

### Issue 1: Jenkins can't access Docker
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue 2: Port 8080 already in use
```bash
# Check what's using port 8080
sudo lsof -i :8080

# Kill if needed
sudo kill -9 PID_NUMBER

# Or change your app to different port
```

### Issue 3: Maven build fails
```bash
# Run manually to see error
cd ~/devops-projects/devops-tomcat-project
mvn clean package

# Check Java version
java -version
```

### Issue 4: Cannot access from browser
- Verify Security Group has port 8080 and 8081 open
- Check EC2 Public IP is correct
- Ensure services are running: `docker ps` and `sudo systemctl status jenkins`

### Issue 5: Low memory errors
```bash
# Check memory
free -h

# Verify swap is active (should show 2GB from setup)
swapon --show

# If swap not active, reactivate it
sudo swapon /swapfile
```

---

## USEFUL COMMANDS REFERENCE

### Docker Commands
```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View logs
docker logs CONTAINER_NAME

# Stop container
docker stop CONTAINER_NAME

# Remove container
docker rm CONTAINER_NAME

# View images
docker images

# Remove image
docker rmi IMAGE_NAME
```

### Docker Compose Commands
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Rebuild and restart
docker compose up -d --build
```

### Jenkins Commands
```bash
# Check Jenkins status
sudo systemctl status jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# View Jenkins logs
sudo journalctl -u jenkins -f
```

### System Monitoring
```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU and processes
top
# Press 'q' to quit

# Check network ports
sudo netstat -tulpn
```

---

## NEXT STEPS FOR LEARNING

1. **Add automated testing** - Integrate JUnit reports
2. **Set up SonarQube** - Code quality analysis
3. **Add email notifications** - Jenkins pipeline notifications
4. **Implement Blue-Green deployment** - Zero downtime updates
5. **Add monitoring** - Prometheus + Grafana
6. **Set up ELK stack** - Centralized logging
7. **Kubernetes deployment** - Container orchestration

---

## COST OPTIMIZATION TIPS

1. **Stop EC2 when not using**:
   - You're charged per hour (~$0.021/hour for t3.small = ~$15/month)
   - Stop instance when done practicing (save 70-80% of costs)
   - Elastic IP: Release if not using (charged when instance stopped)

2. **Use AWS Free Tier**:
   - 750 hours/month of t2.micro or t3.micro (first 12 months)
   - t3.small is NOT free tier but very affordable
   - Monitor usage in AWS Billing dashboard

3. **Clean up resources**:
   ```bash
   # Remove old Docker images
   docker system prune -a
   
   # Remove old Jenkins builds
   # Configure in Jenkins job settings
   ```

---

## PROJECT COMPLETION CHECKLIST

- [ ] EC2 instance launched and accessible
- [ ] MobaXterm connected successfully
- [ ] Java 11, Maven, Git installed
- [ ] Docker and Docker Compose working
- [ ] Application builds with Maven
- [ ] Docker container runs successfully
- [ ] Jenkins installed and accessible
- [ ] Jenkins pipeline configured
- [ ] Successful CI/CD pipeline execution
- [ ] Application accessible from browser
- [ ] GitHub integration working

---

## SUPPORT & RESOURCES

- **AWS Documentation**: https://docs.aws.amazon.com/ec2/
- **Jenkins Documentation**: https://www.jenkins.io/doc/
- **Docker Documentation**: https://docs.docker.com/
- **Your Project Files**: Check README.md and SETUP.md

---

**Author**: Ayman - DevOps Learning Journey
**Date**: February 2026
**Instance Configuration**: All-in-One Setup (Jenkins + Docker + Application)
