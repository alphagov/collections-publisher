class RedirectItem < ActiveRecord::Base
  # `related_tag` is a temporary association to allow a reversable migration.
  belongs_to :related_tag, class_name: 'Tag'
end
