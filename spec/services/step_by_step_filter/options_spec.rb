require 'rails_helper'

RSpec.describe StepByStepFilter::Options do
  it "returns filter options" do
    expected_options = [
      {
        text: "All",
        data_attributes: {
          show: "all"
        },
      },
      {
        text: "Draft",
        value: "draft",
        data_attributes: {
          show: "draft"
        },
      },
      {
        text: "Published",
        value: "published",
        data_attributes: {
          show: "published"
        },
      },
      {
        text: "Scheduled",
        value: "scheduled",
        data_attributes: {
          show: "scheduled"
        },
      }
    ]

    expect(described_class.statuses).to eq(expected_options)
  end
end
