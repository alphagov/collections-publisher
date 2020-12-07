class AnnouncementJsonPresenter
  attr_reader :announcement
  def initialize(announcement)
    @announcement = announcement
  end

  def output
    @output ||=
      {
        "text" => announcement.title.to_s,
        "href" => announcement.path.to_s,
        "published_text" => format_published_text,
      }
  end

  def format_published_text
    announcement.published_at.strftime("Published %-d %B %Y")
  end
end
