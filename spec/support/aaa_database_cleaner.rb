require "database_cleaner"

# This file is named aaa_... to ensure it gets run before any other support
# bits that may create entries in the DB.

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  # Not using around hook due to https://github.com/DatabaseCleaner/database_cleaner/issues/273

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end
  config.before :each, js: true do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
