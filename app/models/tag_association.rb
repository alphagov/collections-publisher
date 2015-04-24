# == Schema Information
#
# Table name: tag_associations
#
#  id          :integer          not null, primary key
#  from_tag_id :integer          not null
#  to_tag_id   :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_tag_associations_on_from_tag_id_and_to_tag_id  (from_tag_id,to_tag_id) UNIQUE
#  index_tag_associations_on_to_tag_id                  (to_tag_id)
#

class TagAssociation < ActiveRecord::Base
  belongs_to :from_tag, class_name: "Tag"
  belongs_to :to_tag, class_name: "Tag"
end
