class CoronavirusPagesController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  before_action :redirect_to_index_if_slug_unknown, only: %w[prepare show]
  layout "admin_layout"

  def index
    links = page_configs.keys.map do |page|
      {
        slug: page.to_s,
        title: page_configs[page][:name],
      }
    end

    render :index, locals: { links: links }
  end

  def prepare
    coronavirus_page
  end

  def show
    coronavirus_page
  end

  def update
    if page_config.nil?
      flash["alert"] = "Page could not be updated because the configuration cannot be found."
    else
      fetch_content_and_push
    end

    redirect_to prepare_coronavirus_page_path
  end

  def publish
    publish_page
    redirect_to prepare_coronavirus_page_path(slug)
  end

private

  def coronavirus_page
    @coronavirus_page ||= updater.page
  end

  def updater
    CoronavirusPages::Updater.new(slug)
  end

  def redirect_to_index_if_slug_unknown
    if page_config.nil?
      flash[:alert] = "'#{slug}' is not a valid page.  Please select from one of those below."
      redirect_to coronavirus_pages_path
    end
  end

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
    page_configs[page_type]
  end

  def slug
    params[:slug] || params[:coronavirus_page_slug]
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

  def page_configs
    CoronavirusPages::Configuration.all_pages
  end
end
