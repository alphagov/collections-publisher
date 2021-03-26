module GovukUrlHelper
  def remove_govuk_from_url(url)
    url.gsub(%r{\Ahttps://www\.gov\.uk}, "")
  end
end
