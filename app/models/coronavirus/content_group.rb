class Coronavirus::ContentGroup < ApplicationRecord
  belongs_to :sub_section, foreign_key: "coronavirus_sub_section_id"
  validates :links, presence: true
  validates :sub_section, presence: true

  serialize :links, Array
end
