#!/usr/bin/env groovy
properties([
    parameters([
        string(name: 'APP_TAG', defaultValue: 'v1', description: 'The tag for the build'),
        booleanParam(name: 'SKIP_TEST', defaultValue: false, description: 'Skip the unit tests stage')
    ])
])
timeout(time: 1, unit: 'HOURS') {
  timestamps {
    elcaPodTemplates.base {
      elcaPodTemplates.maven([
          tag: '3.8-eclipse-temurin-8'
      ]) {
        elcaPodTemplates.oc {
          node(POD_LABEL) {
            elcaStage.gitCheckout()

            stageComplie()

            stageBuildAndDeploy()

            container('maven') {
              stage('Run analysis on newly deployed') {
                withMaven() {
                  sh "mvn sonar:sonar -Dsonar.host.url=http://sonarqube-prj-elcavn-training-day.apps.okd.svc.elca.ch -Dsonar.login=admin -Dsonar.password=adm"
                }
              }
            }
          }
        }
      }
    }
  }
}


def stageComplie() {
  container('maven') {
    stage('Build') {
      withMaven() {
        if (params.SKIP_TEST) {
          sh "mvn clean install"
        } else {
          sh "mvn clean install -DskipTests"
        }
      }
    }
    stage('Run SonarQube Analysis') {
      elcaSonarqube.analyzeWithMaven(
          [
              'sonar.projectKey': 'prj_elcavn-tech-training:devops-dotnet2',
          ]
      )
    }
  }
}

def stageBuildAndDeploy() {
  container('oc') {
    elcaOKDLib = elcaOKDLoader.load()
    openshift.withCluster() {
      openshift.withProject('prj-elcavn-training-devops-day') {
        stageBuild()
        stageDeploy()
      }
    }
  }
}

def stageBuild() {
  stage('Build Docker Image') {
    fileOperations([
        fileCopyOperation(includes: 'target/*.war', targetLocation: './docker', flattenFiles: true)
    ])
    openshift.apply(
        openshift.process(
            readFile('./okd/build.yml'), '-p', "APP_TAG=${params.APP_TAG}"
        )
    )
    elcaOKDLib.buildAndWaitForCompletion('petclinic', '--from-dir ./docker')
  }
}


def stageDeploy() {
  stage('Deploy Petclinic') {
    openshift.apply(
        openshift.process(
            readFile('./okd/deploy.yml'),
            '-p', "CONTAINER_ID=${new Date().format("yyyyMMddHHmmssS", TimeZone.getTimeZone('UTC'))}", "APP_TAG=${params.APP_TAG}"
        )
    )
    elcaOKDLib.waitForDeploymentCompletion('petclinic')
  }
}
