
# CICD Pipeline
 ## links
 jenkins at http://35.246.194.209:8080/
 app at http://34.159.17.155:3000/
 ## the project consists of :
 - a Google Cloud Platform Infrastructure 
 - Google Kubernetes Engine
 - Jenkins nodes master and slave on kubernetes
 - 3 branch git repo application main, blue and green
 - Multi branch pipeline
 ##  idea and automation :
 -terraform is used to spin up a fully private infrastructure with Google kubernetes engine on Google Cloud, then a bastion host is used to connect to kubernetes engine and deploy jenkins master and slave, after that jenkins multibranch pipeline is used, the branch "main" is used for development 
 "blue" and "green" branches are used to create an application image from a dockerfile that is present on the application git repo to implement blue green deplyment strategy.

## Demo

This Repo contains Infrastructure section of the CICD Pipeline project.



this Repo : https://github.com/mohab58977/react-task contains Application, Dockerfile, Jenkinsfile
 
 
## Tools & Plugins


#### Kubernetes :

#### Jenkins :

  - Create CICD pipeline to build and push the image of our app & deploy  on GKE cluster.

##  docker file

- docker file to create an image from app (Jenkins will build and push this image to dockerhub)



## Deployment files

- Ideployment files (blue.yaml & green.yaml & service.yaml) Jenkins will deploy these files on GKE cluster



## Jenkinsfile

1- "CI" stage in the Pipeline will ( clone the github repo & build app image & push image to dockerhub ) "Pipeline will run on Jenkins Slave Pod"


2- "CD" stage in the Pipeline will ( authenticate access to the cluster using Service account which is created with terraform in the infra section & gcloud auth command )
   I added a new credentials "secret file" in jenkins which contains Service account '.json key'


## Feedback

If you have any feedback, please reach out to me at mohab5897@gmail.com
