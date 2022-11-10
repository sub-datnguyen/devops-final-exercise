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

                    stage("Setup env") {
                        elcaEnvironment.setJava('java8')
                        env.MAVEN_OPTS = "-Xmx1G"
                    }

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
                            }
                        }
                    }

                }
            }
        }
    }
}