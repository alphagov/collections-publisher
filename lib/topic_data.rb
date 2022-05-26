# TODO: pull all this data in from content store rather than using a hardcoded csv.
require "csv"
class TopicData
  def initialize(tag_type)
    @tag_type = tag_type
  end

  attr_reader :tag_type

  def all_topics_csv
    CSV.read(Rails.root.join(source_topics_file), headers: true)
  end

  def parent_topics
    regex = /\A(\/.*\/)/
    list = all_topics_csv.map { |row| regex.match(row["base_path"])[0].chop }
    list.uniq
  end

private

  def source_topics_file
    if tag_type == "mainstream_browse_pages"
      "mainstreambrowsepages.csv"
    else
      "specialist_topics.csv"
    end
  end
end
