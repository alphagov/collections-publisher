class CoronavirusPages::ContentBuilder
  attr_reader :coronavirus_page, :errors

  def initialize(coronavirus_page)
    @coronavirus_page = coronavirus_page
    @errors = []
  end

  def data
    @data ||= begin
      validate_content
      data = github_data
      data["content_sections"] = sub_sections_data # Rename to sections when ready to go live
      data["live_stream"] = live_stream_data
      data
    end
  rescue RestClient::Exception => e
    add_error(e.message)
  end

  def success?
    data
    errors.empty?
  end

  def add_error(error)
    errors << error
    errors.flatten!
  end

  def validate_content
    required_keys =
      type.to_sym == :landing ? required_landing_page_keys : required_hub_page_keys
    missing_keys = (required_keys - github_data.keys)
    add_error("Invalid content - please recheck GitHub and add #{missing_keys.join(', ')}.") if missing_keys.any?
  end

  def type
    coronavirus_page.slug.to_sym
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

  def github_raw_data
    YamlFetcher.new(coronavirus_page.raw_content_url).body_as_hash
  end

  def github_data
    @github_data ||= github_raw_data["content"]
  end

  def sub_sections_data
    coronavirus_page.sub_sections.map do |sub_section|
      presenter = SubSectionJsonPresenter.new(sub_section)
      add_error(presenter.errors) unless presenter.success?
      presenter.output
    end
  end

  def live_stream_data
    live_stream = LiveStream.last
    {
      "video_url" => live_stream.url,
      "date" => live_stream.formatted_stream_date,
    }
  end
end
