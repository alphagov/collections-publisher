module StatusHelper
  def status(text, type)
    class_name = {
      published: :success,
      draft: :info,
    }[type.to_sym] || type

    content_tag :span, text, class: "label label-#{class_name}"
  end

  def beta_tag
    status 'In Beta', :warning
  end
end
