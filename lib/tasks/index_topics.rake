desc 'Send all topics to Rummager'
task index_topics: [:environment] do
  Topic.published.find_each do |topic|
    RummagerNotifier.new(topic).notify
  end
end
