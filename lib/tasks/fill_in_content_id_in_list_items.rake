desc "Fill in content ids in list items after adding content_id database column."
task fill_in_content_id_in_list_items: :environment do
  list_item_info = lambda do |l|
    "\"#{l.id}\",\"#{l.list&.tag&.title}\",\"#{l.list&.tag.try(:base_path)}\",\"#{l.list&.name}\",\"#{l.title}\",\"#{l.base_path}\""
  end

  ListItem.find_each do |list_item|
    next if list_item.read_attribute(:content_id).present?

    base_path = list_item.base_path
    list_item.content_id = list_item.list.tag.tagged_document_for_base_path(base_path)&.content_id

    unless list_item.read_attribute(:content_id).present? && list_item.save
      puts "Could not set content_id of the following list item: #{list_item_info[list_item]}"
    end
  rescue StandardError => e
    puts "Exception #{e} raised when trying to set content_id of the following list item: #{list_item_info[list_item]}"
  end
end
