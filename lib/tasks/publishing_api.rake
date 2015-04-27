namespace :publishing_api do

  desc "Send all tags to the publishing-api, skipping any marked as dirty"
  task :republish_all_tags => :environment do

    puts "Sending #{Tag.count} tags to the publishing-api"
    done = 0
    Tag.find_each do |tag|
      if tag.dirty?
        puts "Warning: skipping dirty #{tag.class} #{tag.base_path}"
        next
      end

      PublishingAPINotifier.send_to_publishing_api(tag)
      done += 1
      if done % 100 == 0
        puts "#{done} completed..."
      end
    end
    puts "All done, #{done} tags sent to publishing-api."
  end
end
