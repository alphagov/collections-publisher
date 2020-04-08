Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "publishing_api_notifier" => "PublishingAPINotifier",
  )
end
