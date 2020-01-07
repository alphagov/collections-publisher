desc "Run govuk-lint on all files"
task "lint" do
  sh "rubocop"
  sh "govuk-lint-sass app/assets/stylesheets"
end
