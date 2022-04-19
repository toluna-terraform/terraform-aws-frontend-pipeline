version: 0.2

env:
  parameter-store:
    USER: "/app/bb_user"  
    PASS: "/app/bb_app_pass"
    RELEASE_HOOK_URL: "/app/jira_release_hook"

phases:
  pre_build:
    commands:
      - yum install -y yum-utils
      - yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      - yum install -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib
      - | 
        aws s3 mv s3://${BUCKET}/pre-release/ s3://${BUCKET}/ --recursive
        aws s3 rm s3://${BUCKET}/pre-release/
      - aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/pre-release/**/*" "/pre-release/*"
  build:
    commands:
      - cd service/test
      - yarn add cypress --dev
      - node_modules/.bin/cypress run --reporter junit --reporter-options "mochaFile=results/junit.xml"

reports:
  ${APP_NAME}-${ENV_NAME}-IntegrationTestReport:
    file-format: JUNITXML
    files:
      - '**/junit.xml'
    base-directory: './service/test/results'

        
