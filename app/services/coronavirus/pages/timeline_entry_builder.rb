module Coronavirus::Pages
  class TimelineEntryBuilder
    def create_timeline_entries
      return if timeline_entries_from_yaml.empty?

      Coronavirus::TimelineEntry.transaction do
        page.timeline_entries.delete_all

        timeline_entries_from_yaml.reverse.each do |entry|
          page.timeline_entries.create!(
            heading: entry["heading"],
            content: entry["paragraph"],
          )
        end
      end
    end

  private

    def timeline_entries_from_yaml
      @github_data ||= YamlFetcher.new(page.raw_content_url).body_as_hash
      @github_data.dig("content", "timeline", "list")
    end

    def page
      @page ||= Coronavirus::Page.find_by(slug: "landing")
    end
  end
end
