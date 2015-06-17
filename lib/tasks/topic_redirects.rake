desc "Generate a CSV for router-data redirects"
task :topic_redirects => [:environment] do
  topic_base_paths = Topic.published.only_parents.map(&:base_path).sort

  topic_base_paths.each do |base_path|
    puts "#{base_path},/topic#{base_path},exact"
  end

  subtopic_base_paths = Topic.published.only_children.map(&:base_path).sort

  subtopic_base_paths.each do |base_path|
    puts "#{base_path},/topic#{base_path},exact"
    puts "#{base_path}/email-signup,/topic#{base_path}/email-signup,exact"
    puts "#{base_path}/latest,/topic#{base_path}/latest,exact"
  end
end
