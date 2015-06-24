# == Schema Information
#
# Table name: redirects
#
#  id                       :integer          not null, primary key
#  tag_id                   :integer
#  original_topic_base_path :string(255)      not null
#  from_base_path           :string(255)      not null
#  to_base_path             :string(255)      not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_redirects_on_tag_id  (tag_id)
#

class Redirect < ActiveRecord::Base
  belongs_to :tag
end
