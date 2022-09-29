module HeaderHelper
  # Generates a header with `title` and `breadcrumbs`. Last item in the
  # breadcrumbs array should be a string for the "active" entry.
  def header(title, breadcrumbs:, page_title: nil)
    breadcrumbs = breadcrumbs.compact
    active_item = breadcrumbs.pop

    locals = {
      title:,
      breadcrumbs:,
      page_title: page_title || title,
      active_item: active_item.try(:title) || active_item,
    }

    render layout: "shared/header", locals: locals do
      yield if block_given?
    end
  end

  def tag_header(tag, mode = nil)
    breadcrumbs = [active_navigation_item, tag.parent, tag, mode]

    title = "#{icon tag.sort_mode} #{tag.title_including_parent}"
    title = "#{title}: #{mode}" if mode
    title = "#{title} #{labels_for_tag(tag)}"

    header title, breadcrumbs: breadcrumbs, page_title: tag.title_including_parent do
      yield if block_given?
    end
  end

  def auto_link(object)
    if object.is_a?(ActiveRecord::Base)
      link_to object.title, object
    elsif object.to_s.starts_with?("<a href")
      sanitize object
    else
      link_to object.to_s.humanize, object.to_sym
    end
  end

  # Everything above this comment can be pulled out once we've finished porting
  # over to the design system

  # Generates a header with govuk-tags's

  def govuk_heading_with_parent(tag)
    tag.title_including_parent
  end

  def govuk_tag_heading(tag:, prepend: nil, append: nil)
    context = govuk_status(tag)
    title = if prepend
              "#{prepend} #{tag.title_including_parent}"
            elsif append
              "#{tag.title_including_parent}: #{append}"
            else
              tag.title_including_parent
            end

    locals = if tag.title_including_parent.blank?
               {
                 title: nil,
                 page_title: "Error",
               }
             else
               {
                 context:,
                 title:,
                 page_title: tag.title_including_parent,
               }
             end

    render layout: "shared/govuk_tag_heading", locals: locals do
      yield if block_given?
    end
  end
end
