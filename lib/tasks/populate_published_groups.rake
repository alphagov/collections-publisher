desc 'One-time task to populate Tag#published_groups'
task populate_published_groups: [:environment] do
  Tag.only_children.each do |tag|
    item = CollectionsPublisher.services(:content_store).content_item(tag.base_path)
    unless item
      puts "#{tag.base_path} is missing from the content-store."
      next
    end

    tag.update!(published_groups: item['details']['groups'])
  end
end
