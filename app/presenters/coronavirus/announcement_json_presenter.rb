class Coronavirus::AnnouncementJsonPresenter
  include GovukUrlHelper
  attr_reader :announcement

  def initialize(announcement)
    @announcement = announcement
  end

  def output
    {
      "text" => announcement.title,
      "href" => remove_govuk_from_url(announcement.url),
      "published_text" => announcement.published_on&.strftime("Published %-d %B %Y"),
    }.compact
  end
end
