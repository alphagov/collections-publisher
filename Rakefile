require File.expand_path("config/application", __dir__)
Rails.application.load_tasks

# RSpec shoves itself into the default task without asking, which confuses the ordering.
# https://github.com/rspec/rspec-rails/blob/eb3377bca425f0d74b9f510dbb53b2a161080016/lib/rspec/rails/tasks/rspec.rake#L6
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint spec]
