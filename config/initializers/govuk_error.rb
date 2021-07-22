GovukError.configure do |config|
  config.backtrace_cleanup_callback = lambda do |backtrace|
    Rails.backtrace_cleaner.add_silencer { |line| true }
    Rails.backtrace_cleaner.clean(backtrace)
  end
end
