class CoronavirusController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  def index
    links = all_pages_configuration.keys.map do |page|
      {
        slug: page.to_s,
        title: all_pages_configuration[page][:name],
      }
    end

    render :index, locals: { links: links }
  end

  def show
    if page_config.nil?
      flash[:alert] = "'#{slug}' is not a valid page.  Please select from one of those below."
      redirect_to coronavirus_index_path
    else
      render :show, locals: { page: page_config }
    end
  end

  def update
    if page_config.nil?
      flash["alert"] = "Page could not be updated because the configuration cannot be found."
    else
      fetch_content_and_push
    end

    redirect_to coronavirus_path
  end

  def publish
    publish_page
    redirect_to coronavirus_path(slug)
  end

private

  def publish_page
    Services.publishing_api.publish(page_config[:content_id], update_type)

    flash["notice"] = "Page published!"
  rescue GdsApi::HTTPConflict
    flash["alert"] = "Page already published - update the draft first"
  end

  def fetch_content_and_push
    response = RestClient.get(page_config[:raw_content_url])

    if response.code == 200
      corona_content = YAML.safe_load(response.body)["content"]

      if valid_content?(corona_content, page_type)
        presenter = CoronavirusPagePresenter.new(corona_content, page_config[:base_path])

        with_longer_timeout do
          Services.publishing_api.put_content(page_config[:content_id], presenter.payload)
          flash["notice"] = "Draft content updated"
        rescue GdsApi::HTTPGatewayTimeout
          flash["alert"] = "Updating the draft timed out - please try again"
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
      type == :landing ? required_landing_page_keys : required_hub_page_keys
    missing_keys = (required_keys - content.keys)
    if missing_keys.any?
      flash["alert"] = "Invalid content - please recheck GitHub and add #{missing_keys.join(', ')}."
      return false
    end

    true
  end

  def page_config
    all_pages_configuration[page_type]
  end

  def slug
    params[:slug] || params[:coronavirus_slug]
  end

  def page_type
    slug.to_sym
  end

  def required_landing_page_keys
    %w[
      title
      meta_description
      header_section
      announcements_label
      announcements
      nhs_banner
      sections
      topic_section
      notifications
    ]
  end

  def required_hub_page_keys
    %w[
      title
      header_section
      sections
      topic_section
      notifications
    ]
  end

  def all_pages_configuration
    {
      landing:
        {
          name: "Coronavirus landing page",
          content_id: "774cee22-d896-44c1-a611-e3109cce8eae".freeze,
          raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml".freeze,
          base_path: "/coronavirus",
          github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_landing_page.yml",
        },
      business:
        {
          name: "Business support page",
          content_id: "09944b84-02ba-4742-a696-9e562fc9b29d".freeze,
          raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml".freeze,
          base_path: "/coronavirus/business-support",
          github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_business_page.yml",
        },
      education:
        {
          name: "Education page",
          content_id: "b350e61d-1db9-4cc2-bb44-fab02882ac25".freeze,
          raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_education_page.yml".freeze,
          base_path: "/coronavirus/education-and-childcare",
          github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_education_page.yml",
        },
    }
  end
end
