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

  Tag.only_children.where(dirty: false).each do |tag|
    actual_groups = TopicPresenter.new(tag).build_groups.map(&:stringify_keys)
    published_groups = tag.published_groups
    raise "Non-dirty tag #{tag.id} is actually dirty."
  end
end
