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
                    // CI=true forces react-scripts to run tests once instead of waiting interactively
                    sh 'CI=true npm test'
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
                // NOTE: Change 'sonar-server' to whatever name you gave your SonarQube server in Jenkins config
                withSonarQubeEnv('sonar-server') {
                    sh 'sonar-scanner -Dsonar.projectKey=accounts-dashboard -Dsonar.sources=client/src,flask-integration'
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
        
    }
}
