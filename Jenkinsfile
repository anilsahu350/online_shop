pipeline {
    agent { label "dev" }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = ''
    }

    stages {
        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Git Checkout") {
            steps {
                git branch: 'feature/shopping-cart-devops',
                    url: 'https://github.com/anilsahu350/online_shop.git'
            }
        }

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' 
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=online-shop \
                        -Dsonar.projectKey=online-shop
                    '''
                }
            }
        }

        stage("Code Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }

        stage("OWASP FS Scan") {
            steps {
                script {
                    def start = System.currentTimeMillis()
                    dependencyCheck additionalArguments: '--scan . --exclude node_modules --disableYarnAudit --disableNodeAudit -n',
                                     odcInstallation: 'DP-Check'
                    def end = System.currentTimeMillis()
                    echo "OWASP scan duration: ${(end - start)/1000} seconds"
                }
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage("Trivy File Scan") {
            steps {
                sh 'trivy fs . > trivy.txt'
            }
        }

        stage("Build Docker Image") {
            steps {
                sh 'docker build -t online-shop -f Dockerfile.nginx .'
            }
        }

        stage("Tag & Push to DockerHub") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    script {
                        def imageName = "${DOCKER_USER}/online-shop:latest"
                        env.DOCKER_IMAGE = imageName
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker tag online-shop ${DOCKER_IMAGE}
                            docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }

        

        stage("Deploy to Container") {
            steps {
                sh '''
                    docker rm -f online-shop || true
                    docker run -d --name online-shop -p 3000:80 ${DOCKER_IMAGE}
                '''
            }
        }
    }

    post {
        always {
            script {
                def status = currentBuild.currentResult
                def subjectStatus = status == 'SUCCESS' ? "SUCCESS" : status == 'FAILURE' ? "FAILURE" : "UNSTABLE"
                def emailBody = """
                <html>
                <body>
                    <h2>Build Report - ${subjectStatus}</h2>
                    <p><b>Project:</b> ${env.JOB_NAME}</p>
                    <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>Status:</b> ${status}</p>
                    <p><b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                </body>
                </html>
                """

                emailext(
                    to: 'anilsahu350@gmail.com',
                    subject: "'${subjectStatus}' Online-Shop Build Report",
                    body: emailBody,
                    mimeType: 'text/html',
                    attachLog: true,
                    attachmentsPattern: 'trivy.txt'
                )
            }
        }
    }
}
