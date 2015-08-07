namespace :detailed_guides do
  desc "Relocate detailed guides referenced in Topics"
  task :relocate_to_guidance => :environment do
    panopticon = CollectionsPublisher.services(:panopticon)

    page = 1
    while true
      puts "Fetching page #{page}"
      response = panopticon.get_json("#{panopticon.send(:base_url)}.json?kind=detailed_guide&state=published&page=#{page}")
      if response.count == 0
        break
      else
        detailed_guide_slugs = response.map { |a| a["slug"] }
      end
      page += 1

      puts "Updating #{detailed_guide_slugs.count} items"
      ListItem.where(base_path:
          detailed_guide_slugs.map { |s| s.sub(%r{^guidance/}, "/") }).find_each do |list_item|
        next if list_item.base_path =~ %r{^/guidance}
        puts "Updating #{list_item.base_path} => /guidance#{list_item.base_path}"
        list_item.update_attribute(:base_path, "/guidance#{list_item.base_path}")
      end
    end

    count = Topic.count
    Topic.all.each_with_index do |topic, i|
      ListPublisher.new(topic).perform
      puts "Republished list for #{topic.slug} (#{i + 1}/#{count})"
    end
  end
end
