class Content < ActiveRecord::Base
  belongs_to :list

  validates :index, numericality: {greater_than_or_equal_to: 0}
end
