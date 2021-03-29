# Booster_CI_CD_Project

Create CI/CD pipeline using jenkinsfile to deploy simple django web app as a microservice running on docker container locally

# Steps

1- Fork this repo to your account

2- write dockerfile inside the forked repo to create new image from base image ubuntu and install python3.6 and pip3 and copy the source code files of the app to this image and configure it to start the server when creating container (check the below section for steps to start the django server) 

3- configure ubuntu slave to use it for the pipeline

4- create slck workspace and integrate it with jenkins

5- install any plugin from your choice to create statistics about builds

6- write jenkinsfile with the following four stages for both dev and master branch

- preparation: checkout the code

- build image: build image using the dockerfile

- push image: push the built image to docker registry(docker hub)

- deploy: deploy a container from the pushed image

- notification: send slack message with the build status


7- configure job in jenkins using multibranch pipeline type with the forked git repo url





# Steps to start django server


  install required packages:

      pip3 install -r requirements.txt

  make migrations for DB:

      python3.6 manage.py makemigrations

  apply the migrations:

      python3.6 manage.py migrate

  start the server:

      python3.6 manage.py runserver 0.0.0.0:8000
      
      
      
      
# Expected Behavior

Adding the Jenkins file in either branch will result in the building of the pipeline using a slave with the label "ubuntu_doc",
the branch dev will **create** a docker container named: 

     "django_dev" listening on port 8001 
      
    
and the branch master will create a docker container named:

    "django_master" listening on port 8000 
    
# **Jenkinsfile**
##Agent
```
        agent {label "ubuntu_doc"}
```
This part specifies that the agent that will run this pipeline has the Label "ubuntu_doc"
## Build Stage
```
stage('Build Image'){

       steps{
             sh 'docker build . -t mada96/django:v1.0'
            }
          }
```
This part uses the below explained dockerfile to build an image.
##Push Stage
```
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
```
In this stage the withCredentials() is called to sepcifiy which Credentials on Jenkins Credentials to use for docker and linked by the credentialsID
*the credentials are only accessed by*:
    
    sh 'docker login -u $USERNAME -p $PASSWORD'    
    
 then the image gets pushed to the docker hub repo.
 
 ##Deploy Stage
 Here the slave must have the docker cli and be connected to the docker daemon in order to create the container
 ```
 stage('Deploy'){
                    steps{
                sh 'docker container run -td -p 8000:8000 --name django_master mada96/django:v1.0'

                    }
```
The following part is used to send notifications to Slack
```
post{

                        success{
                        echo 'Success'
                        slackSend color: "good", message: "Master: build done successfully"
                        }
                        failure {
                        echo 'Failed'
                        slackSend color: "bad", message: "Master: Failure Check logs"
                        }

                }

                
                }
```                
 
 
## Dockerfile 
Builds an image and adds the required package and files to run the django App, Also executes commands on creation to spin up the App correctly.
First the docker file **copy** the following:

    simpleApp/
    manage.py
    requirements.txt
    
to the docker image /
and then will change the working directory to "/"
After that it will **update apt and run** the following commands:

    RUN apt-get update -qq
    RUN apt-get install python3.6 -qq
    RUN apt-get install python3-pip -qq
    
  you dont actually need to run because ubuntu comes already with python 3,but i added it for the rare case it doesn't exist.
  
And finally it will execute the following to start the django server on creation:
    
    CMD pip3 install -r requirements.txt; python3 manage.py makemigrations; python3 manage.py migrate; python3 manage.py runserver 0.0.0.0:8000;/bin/bash
    

## Slack
Jenkins is **already integrated with slack** and once either builds of master or dev completes you will receive a notification on the configured workspace and channel
using the following for both master and dev branches (in dev branch master is replaced with dev):

    slackSend color: "good", message: "Master: build done successfully"
    slackSend color: "bad", message: "Master: Failure Check logs"
    

## Multibranch pipeline
There is a Jenkinsfile in **each** branch which jenkins will autoDetect once the multibranch is configured and start execution.
