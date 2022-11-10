#!/usr/bin/env groovy

timeout(time: 1, unit: 'HOURS') {
    timestamps {
        elcaPodTemplates.base {
            elcaPodTemplates.maven([
                    // See https://hub.docker.com/_/maven?tab=tags
                    tag: '3.8-eclipse-temurin-8'
                ]) {
                elcaPodTemplates.oc {
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

                        container('oc') {
                            elcaOKDLib = elcaOKDLoader.load()
                            openshift.withCluster() {
                                openshift.withProject('prj-elcavn-training-devops-day') {
                                    stage('Build Docker Image') {
                                        fileOperations([
                                                fileCopyOperation(includes: 'target/*.war', targetLocation: './docker', flattenFiles: true)
                                        ])
                                        openshift.apply(
                                                openshift.process(
                                                        readFile('./okd/build.yml')
                                                )
                                        )
                                        elcaOKDLib.buildAndWaitForCompletion('devops-final-exercise-day', '--from-dir ./docker')
                                    }

                                    // stage('Deploy Application') {
                                    //     openshift.apply(
                                    //             openshift.process(
                                    //                     readFile('./okd/deploy.yml'),
                                    //                     '-p', "CONTAINER_ID=${new Date().format("yyyyMMddHHmmssS", TimeZone.getTimeZone('UTC'))}",
                                    //             )
                                    //     )
                                    //     elcaOKDLib.waitForDeploymentCompletion('devops-final-exercise-day')
                                    // }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}