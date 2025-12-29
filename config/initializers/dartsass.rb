APP_STYLESHEETS = {
  "application.scss" => "application.css",
}.freeze

all_stylesheets = GovukPublishingComponents::Config.all_stylesheets.merge(APP_STYLESHEETS)
Rails.application.config.dartsass.builds = all_stylesheets

Rails.application.config.dartsass.build_options << " --quiet-deps"
