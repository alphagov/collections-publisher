module ApplicationHelper

  def alert_classes(key)
    key = {
      'notice' => 'warning',
      'alert' => 'warning',
      'error' => 'danger',
    }.fetch(key, key)

    classes = "alert alert-#{key}"
  end

  def website_url(base_path)
    Plek.new.website_root + base_path
  end
end
