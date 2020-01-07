#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    beforeTest: {
      sh("yarn install")
    },
    rubyLintDirs: "",
    publishingE2ETests: true,
    brakeman: true
  )
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-collections-publisher")
}
