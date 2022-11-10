#!/usr/bin/env groovy
properties([
        parameters([
                string(
                        name: 'APP_TAG',
                        defaultValue: 'v1',
                        description: 'The tag for the build'
                ),
        ])
])
timestamps {
    elcaPodTemplates.base {
        elcaPodTemplates.maven([
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
                                                    readFile('./okd/build.yml'),'-p', "APP_TAG=${params.APP_TAG}"
                                            )
                                    )
                                    elcaOKDLib.buildAndWaitForCompletion('petclinic', '--from-dir ./docker')
                                }

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
                        }
                    }

                    container('maven') {
                        stage('Run analysis on newly deployed SonarQube') {
                          withMaven() {
                            sh "mvn sonar:sonar -Dsonar.host.url=http://sonarqube-prj-elca-training-day.apps.okd.svc.elca.ch -Dsonar.login=admin -Dsonar.password=admin"
                          }
                        }
                    }   
                }
            }
        }
    }
}