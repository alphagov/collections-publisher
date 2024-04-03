class DependentDetroyTagsOfTypeTopic < ActiveRecord::Migration[7.1]
  class Tag < ApplicationRecord
    self.inheritance_column = :_type_disabled
    has_many :redirect_routes, dependent: :destroy
    has_many :children, class_name: "Tag", foreign_key: :parent_id, dependent: :nullify
  end

  def change
    Tag.where(type: "Topic").destroy_all
  end
end
