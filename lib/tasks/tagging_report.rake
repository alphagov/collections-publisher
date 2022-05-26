require_relative "../report_writer"
require_relative "../links_fetcher"
require_relative "../topic_data"

require "csv"

namespace :tagging_report do
  desc "fetch all content items tagged to the tree of subtopics for a given parent topic"
  # rake tagging_report:fetch_tagged_pages[topics,"/topic/running-charity"]
  # rake tagging_report:fetch_tagged_pages[mainstream_browse_pages,"/browse/abroad"]

  task :tagged_pages, %i[tag_type base_path] => [:environment] do |_task, args|
    raise "Pass in a tag_type and base_path" unless args[:tag_type] && args[:base_path]

    data = TopicData.new(args[:tag_type])
    csv = data.all_topics_csv
    ReportWriter.new(args[:tag_type], args[:base_path]).tagged_pages(csv)
  end

  desc "add duplicate tagging information to a csv produced from the :tagged_pages task"
  # rake tagging_report:add_duplicate_tagging_info[topics,"/topic/running-charity"]

  task :add_duplicate_tagging_info, %i[tag_type base_path] => [:environment] do |_task, args|
    raise "Pass in a tag_type and base_path" unless args[:tag_type] && args[:base_path]

    reporter = ReportWriter.new(args[:tag_type], args[:base_path])
    file = reporter.tagged_pages_file
    no_file_yet = "The tagged pages csv for this subtopic hasn't been written yet"
    raise no_file_yet unless File.exist?(Rails.root.join(file))

    reporter.add_duplicate_tagging_info(Rails.root.join(file))
  end

  desc "generate full report"
  task :full_report, %i[tag_type] => [:environment] do |_task, args|
    valid_tags = %w[mainstream_browse_pages topics]
    raise "Pass in one of #{valid_tags}" unless valid_tags.include? args[:tag_type]

    data = TopicData.new(args[:tag_type])
    parent_topics = data.parent_topics
    csv = data.all_topics_csv
    parent_topics.each do |topic|
      reporter = ReportWriter.new(args[:tag_type], topic)
      reporter.tagged_pages(csv)
      file = reporter.tagged_pages_file
      no_file_yet = "The tagged pages csv for this subtopic hasn't been written yet"
      raise no_file_yet unless File.exist?(Rails.root.join(file))

      reporter.add_duplicate_tagging_info(Rails.root.join(file))
      puts "#{topic} done"
    end
  end
end
