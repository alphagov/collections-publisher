#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify collections-publisher against content schemas"

exec ./jenkins.sh
