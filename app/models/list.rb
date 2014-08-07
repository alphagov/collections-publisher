class List < ActiveRecord::Base
  has_many :contents, dependent: :destroy
end
