class TagAssociation < ActiveRecord::Base
  belongs_to :from_tag, class_name: "Tag"
  belongs_to :to_tag, class_name: "Tag"
end
