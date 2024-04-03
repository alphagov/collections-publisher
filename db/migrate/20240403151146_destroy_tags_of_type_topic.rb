class DestroyTagsOfTypeTopic < ActiveRecord::Migration[7.1]
  class Tag < ApplicationRecord
    self.inheritance_column = :_type_disabled
    has_many :redirect_routes, dependent: :destroy
  end

  def change
    Tag.where(type: "Topic").destroy_all
  end
end
