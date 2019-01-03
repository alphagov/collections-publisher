class ValidGovukPathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raise URI::InvalidURIError unless value.starts_with?('/')

    Services.content_store.content_item(value)
  rescue GdsApi::ContentStore::ItemNotFound, GdsApi::InvalidUrl, URI::InvalidURIError
    record.errors[attribute] << "This URL isn't a valid target for a redirect on GOV.UK."
  end
end
