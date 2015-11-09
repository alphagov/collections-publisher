class ListItem < ActiveRecord::Base
  belongs_to :list

  validates :index, numericality: {greater_than_or_equal_to: 0}

  attr_accessor :tagged
  alias :tagged? :tagged
end
