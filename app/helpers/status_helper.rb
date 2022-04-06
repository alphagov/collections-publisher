module StatusHelper
  def status(text, type)
    class_name = {
      published: :success,
      draft: :info,
      archived: :default,
    }[type.to_sym] || type

    tag.span text, class: "label label-#{class_name}"
  end

  def labels_for_tag(tag)
    labels = []
    labels << draft_tag if tag.draft?
    labels << dirty_tag if tag.dirty?
    labels << archived_tag if tag.archived?
    sanitize labels.join(" ")
  end

  def dirty_tag
    status "Unpublished changes", :danger
  end

  def archived_tag
    status "Archived", :default
  end

  def draft_tag
    status "draft", :draft
  end

  # Everything above this comment can be pulled out once we've finished porting
  # over to the design system

  def govuk_status(tag_object)
    text, colour = return_tag_text_and_colour(tag_object)
    classes = "govuk-tag govuk-tag--#{colour} govuk-tag--small"

    tag.span text, class: classes
  end

private

  def return_tag_text_and_colour(tag)
    if tag.archived?
      ["archived", :grey]
    elsif tag.dirty?
      ["unpublished changes", :red]
    elsif tag.published?
      ["published", :green]
    elsif tag.draft?
      ["draft", :blue]
    end
  end
end
