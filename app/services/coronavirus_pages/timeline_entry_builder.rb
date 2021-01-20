class CoronavirusPages::TimelineEntryBuilder
  def create_timeline_entries
    return if timeline_entries_from_yaml.empty?

    TimelineEntry.transaction do
      coronavirus_page.timeline_entries.delete_all

      timeline_entries_from_yaml.reverse.each do |entry|
        coronavirus_page.timeline_entries.create!(
          heading: entry["heading"],
          content: entry["paragraph"],
        )
      end
    end
  end

private

  def timeline_entries_from_yaml
    @github_data ||= YamlFetcher.new(coronavirus_page.raw_content_url).body_as_hash
    @github_data.dig("content", "timeline", "list")
  end

  def coronavirus_page
    @coronavirus_page ||= CoronavirusPage.find_by(slug: "landing")
  end
end
