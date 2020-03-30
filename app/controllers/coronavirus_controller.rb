class CoronavirusController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  CONTENT_ID = "774cee22-d896-44c1-a611-e3109cce8eae".freeze
  CONTENT_URL = "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml".freeze

  def index; end

  def update_draft
    response = RestClient.get(CONTENT_URL)

    if response.code == 200
      corona_content = YAML.safe_load(response.body)["content"]

      if valid_content?(corona_content)
        presenter = CoronavirusPagePresenter.new(corona_content)

        with_longer_timeout do
          begin
            Services.publishing_api.put_content(CONTENT_ID, presenter.payload)
            flash["notice"] = "Draft content updated"
          rescue GdsApi::HTTPGatewayTimeout
            flash["alert"] = "Updating the draft timed out - please try again"
          end
        end
      end
    else
      flash["alert"] = "Error received from Github - #{response.code}"
    end

    redirect_to coronavirus_path
  end

  def publish
    begin
      Services.publishing_api.publish(CONTENT_ID, update_type)

      flash["notice"] = "Page published!"
    rescue GdsApi::HTTPConflict
      flash["alert"] = "Page already published - update the draft first"
    end

    redirect_to coronavirus_path
  end

private

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

  def valid_content?(content)
    return false if content.nil?

    missing_keys = (required_landing_page_keys - content.keys)
    if missing_keys.any?
      flash["alert"] = "Invalid content - please recheck Github and add #{missing_keys.join(', ')}."
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
end
