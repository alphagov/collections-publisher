class AddNationalApplicabilityToCoronavirusTimelineEntry < ActiveRecord::Migration[6.0]
  def change
    add_column :coronavirus_timeline_entries, :national_applicability, :string
  end
end
