desc "Load tags from Content API into Collections Publisher."
task :load_tags_from_content_api => :environment do
  require 'gds_api/content_api'

  content_api_endpoint = Plek.new.find("content_api")
  content_api = GdsApi::ContentApi.new(content_api_endpoint)

  puts "There are currently #{Tag.count} tags in the database"
  puts "Fetching all tags from the Content API..."
  tags = content_api.get_list!("#{content_api_endpoint}/tags.json").
         with_subsequent_pages.
         # Only import the tags that are sectors or specialist sectors.
         select { |tag| ["section", "specialist_sector"].include?(tag.details.type) }

  puts "Received a total of #{tags.count} relevant tags"
  puts "Loading tags into Collections Publisher..."
  tags.each do |api_tag|
    unless Tag.where(slug: api_tag.slug).any?
      case api_tag.details.type
      when "section"
        klass = MainstreamBrowsePage
      when "specialist_sector"
        klass = Topic
      end

      tag = klass.new(slug: api_tag.slug,
                      description: api_tag.details.description,
                      title: api_tag.title)
      tag.save!
    end
  end

  # On the first run of this task, the tags might not exist in the database.
  # Traverse through all fetched tags again and assign parents accodingly.
  puts "Assigning child tags to parents..."
  tags.each do |api_tag|
    existing_tag = Tag.where(slug: api_tag.slug).first

    if existing_tag.parent.nil? and not api_tag.parent.nil?
      parent = Tag.where(slug: api_tag.parent.slug).first
      existing_tag.parent = parent
      existing_tag.save!
    end
  end

  puts "Publishing all 'live' tags"
  tags.each do |api_tag|
    existing_tag = Tag.where(slug: api_tag.slug).first

    if api_tag.state == "live" && !existing_tag.published?
      existing_tag.publish
      existing_tag.save!
    end
  end

  puts "There are now #{Tag.count} tags in the database"
  puts "Finished loading tags"
end
