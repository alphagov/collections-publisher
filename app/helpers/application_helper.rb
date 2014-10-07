module ApplicationHelper

  def alert_classes(key)
    classes = "alert alert-"

    if key == :notice || key == :alert
      key = "warning"
    end

    classes + key
  end

end
