GovukError.configure do |config|
  config.backtrace_cleanup_callback = lambda do |backtrace|
    Rails.backtrace_cleaner.add_silencer { |line| /action_dispatch/.match?(line) }
    Rails.backtrace_cleaner.clean(backtrace)
  end
end
