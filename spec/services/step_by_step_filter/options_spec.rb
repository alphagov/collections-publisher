require 'rails_helper'

RSpec.describe StepByStepFilter::Options do
  it "returns filter options with the default selected" do
    expected_options = [
      {
        text: "All",
        data_attributes: {
          show: "all"
        },
        selected: true,
      },
      {
        text: "Draft",
        value: "draft",
        data_attributes: {
          show: "draft"
        },
        selected: false,
      },
      {
        text: "Published",
        value: "published",
        data_attributes: {
          show: "published"
        },
        selected: false,
      },
      {
        text: "Scheduled",
        value: "scheduled",
        data_attributes: {
          show: "scheduled"
        },
        selected: false,
      }
    ]

    expect(described_class.statuses).to eq(expected_options)
  end

  it "returns filter options with the selected status" do
    expected_options = [
      {
        text: "All",
        data_attributes: {
          show: "all"
        },
        selected: false,
      },
      {
        text: "Draft",
        value: "draft",
        data_attributes: {
          show: "draft"
        },
        selected: false,
      },
      {
        text: "Published",
        value: "published",
        data_attributes: {
          show: "published"
        },
        selected: false,
      },
      {
        text: "Scheduled",
        value: "scheduled",
        data_attributes: {
          show: "scheduled"
        },
        selected: true,
      }
    ]

    expect(described_class.statuses("scheduled")).to eq(expected_options)
  end
end
