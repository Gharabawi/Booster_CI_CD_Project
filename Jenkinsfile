pipeline{
        agent {label "ubuntu_doc"}

        stages{
                stage('Preparation'){
                        steps{
                        git 'https://github.com/mada-ou/Booster_CI_CD_Project.git'

                        }
                }
                stage('Build Image'){

                steps{
                sh 'docker build . -t mada96/django:v1.0'
                }
                }
                stage('Push Image'){

                steps{
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                // available as an env variable, but will be masked if you try to print it out any which way
                // note: single quotes prevent Groovy interpolation; expansion is by Bourne Shell, which is what you want
                sh 'docker login -u $USERNAME -p $PASSWORD'
                
                }
                sh 'docker push mada96/django:v1.0'
                }
                }
                stage('Deploy'){
                    steps{
                sh 'docker container run -td -p 8000:8000 --name django_master mada96/django:v1.0'

                    }
                
                

                post{

                        success{
                        echo 'Success'
                        slackSend color: "good", message: "build done successfully"
                        }
                        failure {
                        echo 'Failed'
                        slackSend color: "bad", message: "Failure Check logs"
                        }

                }

                
                }




}
}
