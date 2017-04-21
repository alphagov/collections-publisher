# Be sure to restart your server when you modify this file.

# HTML generator for displaying errors that come from Active Model
ActionView::Base.field_error_proc = Proc.new do |html_tag, _|
  html_tag
end
