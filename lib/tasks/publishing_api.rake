namespace :publishing_api do

  desc "Send all tags to the publishing-api, skipping any marked as dirty"
  task :send_all_tags => :environment do
    republish_tags(Tag.all)
  end

  desc "Send all published tags to the publishing-api, skipping any marked as dirty"
  task :send_published_tags => :environment do
    republish_tags(Tag.published)
  end

  def republish_tags(tags)
    puts "Sending #{tags.count} tags to the publishing-api"
    done = 0
    tags.find_each do |tag|
      PublishingAPINotifier.send_to_publishing_api(tag)
      done += 1
      if done % 100 == 0
        puts "#{done} completed..."
      end
    end
    puts "Done: #{done} tags sent to publishing-api."

    puts "Sending root browse page to publishing-api"
    CollectionsPublisher.services(:publishing_api).put_content_item("/browse", RootBrowsePagePresenter.new.render_for_publishing_api)

    puts "All done"
  end
end
