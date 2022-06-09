class ReportWriter
  def initialize(tag_type, parent_base_path, file_maker)
    @tag_type = tag_type
    @parent_base_path = parent_base_path
    @file_maker = file_maker
  end

  attr_reader :tag_type, :parent_base_path, :file_maker

  # produce a csv of all content items tagged to the given browse tree
  def tagged_pages
    make_directory
    headers = %i[base_path content_id subtopic]
    new_csv = CSV.open(tagged_pages_file, "a+", write_headers: true, headers: headers)
    all_topics_csv.each do |row|
      next unless row["base_path"].starts_with?(parent_base_path)

      begin
        response = LinksFetcher.new(row["content_id"]).get_linked_items(tag_type)
        if response
          response.to_hash.each do |page|
            new_csv << [page["base_path"], page["content_id"], row["base_path"]]
          end
        end
      rescue GdsApi::TimedOutException, Timeout::Error => e
        puts "Failed to fetch pages for #{row['base_path']}"
        raise e
      end
    end
    new_csv.close
  end

  def add_duplicate_tagging_info(tagged_pages_file)
    tagged_pages_csv = CSV.read(tagged_pages_file, headers: true)
    new_column = "#{duplicate_tag}_ids"

    duplicate_tagging_file = Tempfile.new
    duplicate_tagging_csv =
      CSV.open(duplicate_tagging_file, "a+", headers: tagged_pages_csv.headers << new_column, write_headers: true)

    begin
      tagged_pages_csv.each do |row|
        response = LinksFetcher.new(row["content_id"]).get_links
        if response
          row << { new_column: response.to_hash.dig("links", duplicate_tag) }
          duplicate_tagging_csv << row
        end
      end
    rescue GdsApi::TimedOutException, Timeout::Error => e
      puts "Failed to fetch #{duplicate} for #{parent_base_path}"
      raise e
    end
    duplicate_tagging_csv.close
    FileUtils.move(duplicate_tagging_file.path, tagged_pages_file)
  end

  delegate :make_directory, to: :file_maker

  def tagged_pages_file
    file_maker.file_path
  end

  def duplicate_tag
    tag_type == "topics" ? "mainstream_browse_pages" : "topics"
  end

  def all_topics_csv
    TopicData.new(tag_type).all_topics_csv
  end
end
