#!/usr/bin/env groovy

timestamps {
  elcaPodTemplates.base {
   elcaPodTemplates.maven([
          tag: '3.8-eclipse-temurin-8', 
        ]) {
      node(POD_LABEL) {
        elcaStage.gitCheckout()

        container('maven') {
          stage('Build') {
            withMaven() {
              sh 'mvn clean install'
            }
          }

           stage('Run SonarQube Analysis') {
            elcaSonarqube.analyzeWithMaven()
          }          
        }
        
        // container('oc') {
        //   elcaOKDLib = elcaOKDLoader.load()
        //   openshift.withCluster() {
        //     openshift.withProject('prj-elcavn-training-devops-day') {
        //       stage('Build Docker Image') {
        //         fileOperations([
        //           fileCopyOperation(includes: 'target/*.war', targetLocation: './docker', flattenFiles: true)
        //         ])
        //         openshift.apply(
        //           openshift.process(
        //             readFile('./okd/build.yml')
        //           )
        //         )
        //         elcaOKDLib.buildAndWaitForCompletion('petclinic', '--from-dir ./docker')
        //       }
        //     }
        //   }
        // }
      }
    }
  }
}
