pipeline {
    // Defines that this pipeline can run on any available Jenkins agent
    agent any

    stages {
        
        // STAGE 1: Pull the latest code from the repository
        stage('Git Checkout') {
            steps {
                echo 'Checking out code from Git...'
                checkout scm
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
        
    }
}
