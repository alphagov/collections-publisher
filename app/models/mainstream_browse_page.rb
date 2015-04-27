# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  slug        :string(255)      not null
#  title       :string(255)      not null
#  description :string(255)
#  parent_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_id  :string(255)      not null
#  state       :string(255)      not null
#
# Indexes
#
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#  tags_parent_id_fk                 (parent_id)
#

class MainstreamBrowsePage < Tag
  has_many :topics, through: :tag_associations, source: :to_tag

  def base_path
    "/browse#{super}"
  end
end
