class AbsolutePathOrHttpsUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    uri = URI.parse(value)

    absolute_https = uri.absolute? && uri.scheme == "https"
    absolute_path = uri.relative? && uri.path.starts_with?("/") && value.starts_with?(uri.path)

    if !absolute_https && !absolute_path
      record.errors.add(attribute, "needs to be a https:// URL or a path prefixed with /")
    end
  rescue URI::InvalidURIError
    record.errors.add(attribute, "is not a valid URL")
  end
end
