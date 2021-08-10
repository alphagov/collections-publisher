class Coronavirus::CoronavirusYaml < ApplicationRecord
  self.table_name = "coronavirus_yamls"

  belongs_to :page, foreign_key: "coronavirus_page_id", optional: false
end
