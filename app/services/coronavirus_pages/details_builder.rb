class CoronavirusPages::DetailsBuilder
  attr_reader :coronavirus_page

  def initialize(coronavirus_page)
    @coronavirus_page = coronavirus_page
  end

  def data
    @data ||= begin
      data = github_data
      data[:content_sections] = model_data # Rename to sections when ready to go live
      data.deep_stringify_keys!
      data
    end
  rescue RestClient::Exception => e
    errors << e.message
  end

  def success?
    errors.empty?
  end

  def errors
    @errors ||= []
  end

  def github_raw_data
    YamlFetcher.new(coronavirus_page.raw_content_url).body_as_hash
  end

  def github_data
    github_raw_data[:content]
  end

  def model_data
    sub_sections_data
  end

  def sub_sections_data
    coronavirus_page.sub_sections.map do |sub_section|
      SubSectionJsonPresenter.new(sub_section).output
    end
  end
end
