#!/bin/bash

export REPO_NAME=${REPO_NAME:-"alphagov/collections-publisher"}
curl https://raw.githubusercontent.com/alphagov/govuk-ci-scripts/master/rails-app.sh | bash
