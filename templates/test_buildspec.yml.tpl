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
  build:
    commands:
      - cd service/test
      - yarn add cypress --dev
      - yarn test --config-file=cypress.${ENV_NAME}.json

reports:
  ${APP_NAME}-${ENV_NAME}-IntegrationTestReport:
    file-format: JUNITXML
    files:
      - '**/junit.xml'
    base-directory: './service/test/results'

        
