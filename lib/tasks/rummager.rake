namespace :rummager do
  desc 'Send all tags to Rummager'
  task index_tags: [:environment] do
    Tag.published.find_each do |tag|
      RummagerNotifier.new(tag).notify
    end
  end
end
