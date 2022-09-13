version: 0.2

env:
  parameter-store:
    USER: "/app/bb_user"
    PASS: "/app/bb_app_pass"
    ADO_USER: "/app/codepipeline_ado_user"
    ADO_PASS: "/app/codepipeline_ado_pat"
    RELEASE_HOOK_URL: "/app/jira_release_hook"

phases:
  pre_build:
    commands:
      - yum install -y yum-utils
      - yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      - yum install -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib
      # npm auth
      - |
      npm config set @toluna-ui-toolkit:registry https://pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/
      npm config set //pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/:_password $ADO_PASS
      npm config set //pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/:username $ADO_USER
      npm config set //pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/:email ofir.oron@toluna.com
      npm config ls -l
  build:
    commands:
      - cd service/test
      - yarn add cypress --dev
      - yarn test --config-file=cypress.config.${ENV_NAME}.js

reports:
  ${APP_NAME}-${ENV_NAME}-IntegrationTestReport:
    file-format: JUNITXML
    files:
      - '**/junit.xml'
    base-directory: './service/test/results'


