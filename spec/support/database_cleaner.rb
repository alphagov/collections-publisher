require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.around :each do |example|
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
