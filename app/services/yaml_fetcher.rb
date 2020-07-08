class YamlFetcher
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def response
    @response ||= RestClient.get(cache_busted_url)
  end

  def success?
    response.code == 200
  rescue RestClient::Unauthorized
    false
  end

  delegate :body, to: :response

  def body_as_hash
    @body_as_hash ||= YAML.safe_load(body)
  end

private

  def cache_busted_url
    uri = Addressable::URI.parse(url)

    cache_bust = { "cache-bust" => Time.zone.now.to_i }
    uri.query_values = (uri.query_values || {}).merge(cache_bust)
    uri.to_s
  end
end
