#!/usr/bin/env groovy

library("govuk")

node {
  // Run against the MySQL 8 Docker instance on GOV.UK CI
  govuk.setEnvar("TEST_DATABASE_URL", "mysql2://root:root@127.0.0.1:33068/collections_publisher_test")

  govuk.buildProject(
    rubyLintDirs: "",
    brakeman: true
  )
}
