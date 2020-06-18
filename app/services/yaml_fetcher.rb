class YamlFetcher
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def response
    @response ||= RestClient.get(url)
  end

  def success?
    response.code == 200
  rescue RestClient::Unauthorized
    false
  end

  delegate :body, to: :response

  def body_as_hash
    @body_as_hash ||= YAML.safe_load(body).deep_symbolize_keys
  end
end
