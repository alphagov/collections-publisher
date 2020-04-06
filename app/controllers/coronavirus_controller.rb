class CoronavirusController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  def index; end

  def landing
    @github_content_url = value_object[:landing][:github_url]
    @base_path = value_object[:landing][:base_path]
  end

  def business
    @github_content_url = value_object[:business][:github_url]
    @base_path = value_object[:business][:base_path]
  end

  def update_landing
    fetch_content_and_push(:landing)
    redirect_to coronavirus_landing_path
  end

  def update_business
    fetch_content_and_push(:business)
    redirect_to coronavirus_business_path
  end

  def publish_landing
    publish_page(:landing)
    redirect_to coronavirus_landing_path
  end

  def publish_business
    publish_page(:business)
    redirect_to coronavirus_business_path
  end

private

  def publish_page(type)
    begin
      Services.publishing_api.publish(value_object[type][:content_id], update_type)

      flash["notice"] = "Page published!"
    rescue GdsApi::HTTPConflict
      flash["alert"] = "Page already published - update the draft first"
    end
  end

  def fetch_content_and_push(type)
    page = value_object[type]

    response = RestClient.get(page[:raw_content_url])

    if response.code == 200
      corona_content = YAML.safe_load(response.body)["content"]

      if valid_content?(corona_content, type)
        presenter = CoronavirusPagePresenter.new(corona_content, page[:base_path])

        with_longer_timeout do
          begin
            Services.publishing_api.put_content(page[:content_id], presenter.payload)
            flash["notice"] = "Draft content updated"
          rescue GdsApi::HTTPGatewayTimeout
            flash["alert"] = "Updating the draft timed out - please try again"
          end
        end
      end
    else
      flash["alert"] = "Error received from GitHub - #{response.code}"
    end
  end

  def with_longer_timeout
    prior_timeout = Services.publishing_api.client.options[:timeout]
    Services.publishing_api.client.options[:timeout] = 10

    begin
      yield
    ensure
      Services.publishing_api.client.options[:timeout] = prior_timeout
    end
  end

  def update_type
    major_update? ? "major" : "minor"
  end

  def major_update?
    params["update-type"] == "major"
  end

  def valid_content?(content, type)
    return false if content.nil?

    required_keys =
      type == :landing ? required_landing_page_keys : required_business_page_keys
    missing_keys = (required_keys - content.keys)
    if missing_keys.any?
      flash["alert"] = "Invalid content - please recheck GitHub and add #{missing_keys.join(', ')}."
      return false
    end

    true
  end

  def required_landing_page_keys
    %w(
      title
      meta_description
      stay_at_home
      guidance
      announcements_label
      announcements
      nhs_banner
      sections
      topic_section
      notifications
    )
  end

  def required_business_page_keys
    %w(
      title
      header_section
      guidance_section
      related_links
      announcements_label
      announcements
      other_announcements
      guidance_section
      sections
      topic_section
      notifications
    )
  end

  def value_object
    {
      landing:
        { content_id: "774cee22-d896-44c1-a611-e3109cce8eae".freeze,
          raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml".freeze,
          base_path: "/coronavirus",
          github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_landing_page.yml" },
      business:
        { content_id: "09944b84-02ba-4742-a696-9e562fc9b29d".freeze,
          raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml".freeze,
          base_path: "/coronavirus/business-support",
          github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_business_page.yml" },
    }
  end
end
