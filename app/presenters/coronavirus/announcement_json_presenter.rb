class Coronavirus::AnnouncementJsonPresenter
  attr_reader :announcement
  def initialize(announcement)
    @announcement = announcement
  end

  def output
    {
      "text" => announcement.title.to_s,
      "href" => announcement.url.to_s,
      "published_text" => announcement.published_at&.strftime("Published %-d %B %Y"),
    }.compact
  end
end
