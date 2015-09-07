# == Schema Information
#
# Table name: tags
#
#  id               :integer          not null, primary key
#  type             :string(255)
#  slug             :string(255)      not null
#  title            :string(255)      not null
#  description      :string(255)
#  parent_id        :integer
#  created_at       :datetime
#  updated_at       :datetime
#  content_id       :string(255)      not null
#  state            :string(255)      not null
#  dirty            :boolean          default(FALSE), not null
#  beta             :boolean          default(FALSE)
#  published_groups :text(16777215)
#  child_ordering   :string(255)      default("alphabetical"), not null
#  index            :integer          default(0), not null
#
# Indexes
#
#  index_tags_on_content_id          (content_id) UNIQUE
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#  tags_parent_id_fk                 (parent_id)
#

class Topic < Tag
  has_many :mainstream_browse_pages, through: :reverse_tag_associations, source: :from_tag

  alias subtopic? has_parent?

  def legacy_tag_type
    'specialist_sector'
  end

  def base_path
    "/topic/#{full_slug}"
  end

  def subroutes
    return [] unless subtopic?
    %w[/latest /email-signup]
  end

  def dependent_tags
    if has_parent?
      [parent]
    else
      []
    end
  end
end
