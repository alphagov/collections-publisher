# config/initializers/govuk_publishing_components.rb
GovukPublishingComponents.configure do |c|
  c.component_guide_title = "Collections Publisher"
  c.application_print_stylesheet = nil

  c.application_stylesheet = "admin_layout"
  c.application_javascript = "admin_layout"
end
