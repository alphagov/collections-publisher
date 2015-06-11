module StatusHelper
  def status(text, type)
    class_name = {
      published: :success,
      draft: :info,
    }[type.to_sym] || type

    content_tag :span, text, class: "label label-#{class_name}"
  end

  def labels_for_tag(tag)
    labels = []
    labels << draft_tag if tag.draft?
    labels << beta_tag if tag.beta?
    labels << dirty_tag if tag.dirty?
    labels.join(' ')
  end

  def beta_tag
    status 'In Beta', :warning
  end

  def dirty_tag
    status 'Unpublished changes', :danger
  end

  def draft_tag
    status 'draft', :draft
  end
end
