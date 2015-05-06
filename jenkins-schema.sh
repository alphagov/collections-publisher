#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify collections-publisher against content schemas"
export TEST_TASK="spec:schema"

exec ./jenkins.sh
