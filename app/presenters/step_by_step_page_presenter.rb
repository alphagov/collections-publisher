class StepByStepPagePresenter
  include Rails.application.routes.url_helpers
  include TimeOptionsHelper
  attr_reader :step_by_step_page

  def initialize(step_by_step_page)
    @step_by_step_page = step_by_step_page
  end

  def summary_metadata
    items = {
      "Status" => step_by_step_page.status.humanize,
      "Last saved" => last_saved,
      "Created" => format_full_date_and_time(step_by_step_page.created_at),
    }

    if step_by_step_page.links_checked?
      items.merge!(
        "Links checked" => format_full_date_and_time(step_by_step_page.links_last_checked_date)
      )
    end
    items
  end

  def summary_list_params
    params = {
      borderless: true,
      id: "content",
      title: "Content",
      items: [
        {
          field: "Title",
          value: step_by_step_page.title
        },
        {
          field: "Slug",
          value: step_by_step_page.slug
        },
        {
          field: "Introduction",
          value: step_by_step_page.introduction
        },
        {
          field: "Description",
          value: step_by_step_page.description
        }
      ]
    }
    if step_by_step_page.can_be_edited?
      params.merge!(edit: {
        href: edit_step_by_step_page_path(step_by_step_page),
        data_attributes: {
          gtm: "edit-title-summary-body"
        }
      })
    end
    params
  end

  def steps_section_config
    steps_section_config = {
      title: "Steps",
      id: "steps",
      borderless: true
    }

    if step_by_step_page.can_be_edited? && step_by_step_page.steps.any?
      steps_section_config.merge!(edit: {
        link_text: "Reorder",
        href: step_by_step_page_reorder_path(step_by_step_page),
        data_attributes: {
          gtm: "reorder-steps"
        }
      })
    end

    steps_section_config
  end

  def sidebar_settings
    {
      field: "Sidebar settings",
      edit: {
        link_text: step_by_step_page.can_be_edited? ? "Edit" : "View",
        href: step_by_step_page_navigation_rules_path(step_by_step_page),
        data_attributes: {
          gtm: "edit-sidebar-settings"
        }
      }
    }
  end

  def secondary_links_settings
    {
      field: "Secondary links",
      edit: {
        link_text: step_by_step_page.can_be_edited? ? "Edit" : "View",
        href: step_by_step_page_secondary_content_links_path(step_by_step_page),
        data_attributes: {
          gtm: "edit-secondary-links"
        }
      }
    }
  end

  def last_saved
    last_saved_time = format_full_date_and_time(step_by_step_page.updated_at)
    return "#{last_saved_time} by #{step_by_step_page.assigned_to}" if assigned?

    last_saved_time
  end

  def assigned?
    step_by_step_page.assigned_to.present?
  end
end
