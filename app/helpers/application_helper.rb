module ApplicationHelper

  def alert_classes(key)
    classes = "alert alert-"

    if key == :notice || key == :alert
      key = "warning"
    end

    classes + key
  end

  def website_url(base_path)
    Plek.new.website_root + base_path
  end
end
