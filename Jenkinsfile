pipeline {
    // Defines that this pipeline can run on any available Jenkins agent
    agent any

    stages {
        
        // STAGE 1: Pull the latest code from the repository
        stage('Git Checkout') {
            steps {
                echo 'Checking out code from Git...'
                // Explicitly cloning your repository since this script is pasted directly in Jenkins
                git branch: 'main', url: 'https://github.com/Arun-KumarRavi/project-repo.git'
            }
        }

        // STAGE 2: Navigate into the client folder and install React dependencies
        stage('Install Frontend Dependencies') {
            steps {
                echo 'Installing React (Frontend) Dependencies...'
                dir('client') {
                    // Note: Change 'sh' to 'bat' if your Jenkins agent runs on Windows instead of Linux
                    sh 'npm install --legacy-peer-deps'
                }
            }
        }

        // STAGE 3: Navigate into the flask folder and install Python dependencies
        stage('Install Backend Dependencies') {
            steps {
                echo 'Installing Flask (Backend) Dependencies...'
                dir('flask-integration') {
                    // Using the venv you just installed to create an isolated environment!
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        // STAGE 4: Run React tests
        stage('Frontend Tests') {
            steps {
                echo 'Running Frontend Tests...'
                dir('client') {
                    // CI=true forces react-scripts to run tests once
                    // --passWithNoTests prevents the pipeline from failing if you haven't written any tests yet
                    sh 'CI=true npm test -- --passWithNoTests'
                }
            }
        }

        // STAGE 5: Run Python tests
        stage('Backend Tests') {
            steps {
                echo 'Running Backend Tests...'
                dir('flask-integration') {
                    // Activate venv, install pytest, and run the dummy test file
                    sh '''
                        . venv/bin/activate
                        pip install pytest
                        pytest
                    '''
                }
            }
        }

        // STAGE 6: Static Application Security Testing (SAST)
        stage('SonarQube Scan') {
            steps {
                echo 'Running SonarQube Analysis...'
                script {
                    // This tells Jenkins to automatically grab the Sonar Scanner tool we configure next!
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('sonar-server') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=accounts-dashboard -Dsonar.sources=client/src,flask-integration"
                    }
                }
            }
        }

        // STAGE 7: Wait for SonarQube to pass/fail the code
        stage('Quality Gate') {
            steps {
                echo 'Waiting for Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        // STAGE 8: Trivy Filesystem Scan
        stage('Trivy FS Scan') {
            steps {
                echo 'Scanning filesystem for vulnerabilities and secrets...'
                sh 'trivy fs .'
            }
        }

        // ----------------------------------------------------
        // FRONTEND CONTAINER PHASE
        // ----------------------------------------------------

        // STAGE 9: Build Frontend Image
        stage('Build Frontend Image') {
            steps {
                echo 'Building React Docker Image...'
                dir('client') {
                    sh 'docker build -t accounts-frontend:latest .'
                }
            }
        }

        // STAGE 10: Scan Frontend Image
        stage('Trivy Scan Frontend Image') {
            steps {
                echo 'Scanning React Docker Image for CVEs...'
                sh 'trivy image accounts-frontend:latest'
            }
        }

        // STAGE 11: Push Frontend Image
        stage('Push Frontend Image') {
            steps {
                echo 'Pushing Frontend Image to Registry...'
                // Ensure you created 'docker-hub-credentials' in Jenkins Credentials!
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag accounts-frontend:latest $DOCKER_USER/accounts-frontend:latest'
                    sh 'docker push $DOCKER_USER/accounts-frontend:latest'
                }
            }
        }

        // ----------------------------------------------------
        // BACKEND CONTAINER PHASE
        // ----------------------------------------------------

        // STAGE 12: Build Backend Image
        stage('Build Backend Image') {
            steps {
                echo 'Building Flask Docker Image...'
                dir('flask-integration') {
                    sh 'docker build -t accounts-backend:latest .'
                }
            }
        }

        // STAGE 13: Scan Backend Image
        stage('Trivy Scan Backend Image') {
            steps {
                echo 'Scanning Flask Docker Image for CVEs...'
                sh 'trivy image accounts-backend:latest'
            }
        }

        // STAGE 14: Push Backend Image
        stage('Push Backend Image') {
            steps {
                echo 'Pushing Backend Image to Registry...'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag accounts-backend:latest $DOCKER_USER/accounts-backend:latest'
                    sh 'docker push $DOCKER_USER/accounts-backend:latest'
                }
            }
        }
        
    }
}
