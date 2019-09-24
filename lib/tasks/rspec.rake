if Rails.env.development? || Rails.env.test?
  require "rspec/core/rake_task"
end
