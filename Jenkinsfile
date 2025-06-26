pipeline {
    agent any

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
                git branch: 'feature/shopping-cart-devops', url: 'https://github.com/anilsahu350/online_shop.git'
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

      
        stage("OWASP FS SCAN") {
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
                sh "trivy fs . > trivy.txt"
            }
        }

        stage("Build Docker Image") {
            steps {
                sh "docker build -t online-shop -f Dockerfile.nginx ."
            }
        }

        stage('Tag & Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        def dockerImage = "${DOCKER_USER}/online-shop:latest"
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker tag online-shop $dockerImage
                            docker push $dockerImage
                        """
                        // Save image name for next stage
                        env.DOCKER_IMAGE = dockerImage
                    }
                }
            }
        }

       stage("Docker Scout Image") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker scout quickview ${env.DOCKER_IMAGE}
                        docker scout cves ${env.DOCKER_IMAGE}
                        docker scout recommendations ${env.DOCKER_IMAGE}
                    """
                }
            }
        }

        stage("Deploy to Container") {
            steps {
                sh """
                    docker rm -f online-shop || true
                    docker run -d --name online-shop -p 3000:80 ${env.DOCKER_IMAGE}
                """
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
                <div style="padding: 10px;">
                    <p><b>Project:</b> ${env.JOB_NAME}</p>
                    <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>Status:</b> ${status}</p>
                    <p><b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                </div>
            </body>
            </html>
            """

            emailext(
                attachLog: true,
                subject: "'${subjectStatus}' Online-Shop Project Build Result",
                body: emailBody,
                to: 'anilsahu350@gmail.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy.txt'
            )
        }
    }
}
