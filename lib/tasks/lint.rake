desc "Run govuk-lint on all files"
task lint: :environment do
  sh "rubocop"
  sh "scss-lint app/assets/stylesheets"
end
