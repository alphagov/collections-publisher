class YoutubeUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    @record = record
    @attribute = attribute
    @value = value
    if value.present?
      code = response_code(parsed_url)
      record_error("is not valid. Please check it and try again.") unless code == 200
    end
  end

private

  def record_error(msg)
    @record.errors[@attribute] << msg
  end

  def parsed_url
    uri = URI.parse(@value)
    if uri.host == "www.youtube.com" && uri.scheme == "https"
      uri.to_s
    end
  rescue URI::InvalidURIError
    nil
  end

  def response_code(url = nil)
    return if url.nil?

    begin
      RestClient.get(url).code
    rescue RestClient::Exception => e
      e.http_code
    end
  end
end
