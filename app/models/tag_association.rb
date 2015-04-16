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

class TagAssociation < ActiveRecord::Base
  belongs_to :from_tag, class_name: "Tag"
  belongs_to :to_tag, class_name: "Tag"
end
