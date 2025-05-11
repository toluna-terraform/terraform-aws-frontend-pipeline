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
      - yum install -y libgbm
  build:
    commands:
      - cd service/test
      - |
        npm config set @toluna:registry https://pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/
        npm config set //pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/:_password $ADO_PASS
        npm config set //pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/:username $ADO_USER
        npm config set //pkgs.dev.azure.com/Toluna/_packaging/Toluna/npm/registry/:email jenwin1@toluna.com
        npm config ls -l
      - yarn
      - |
        if [ "${TESTS_REPORT_ENABLED}" == "true" ]; then
          yarn test --env-name=${ENV_NAME} --write-report
        else
          yarn test --env-name=${ENV_NAME}
        fi     

reports:
  ${APP_NAME}-${ENV_NAME}-IntegrationTestReport:
    file-format: JUNITXML
    files:
      - '**/junit.xml'
    base-directory: './service/test/results'


