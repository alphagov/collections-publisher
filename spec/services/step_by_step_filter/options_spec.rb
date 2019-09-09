require 'rails_helper'

RSpec.describe StepByStepFilter::Options do
  it "returns filter options with the default selected" do
    subject = described_class.statuses

    all_option = {
      text: "All",
      data_attributes: {
        show: "all"
      },
      selected: true,
    }

    expect(subject).to include(all_option)

    StepByStepPage::STATUSES.each do |status|
      status_option = {
        text: status.humanize,
        value: status,
        data_attributes: {
          show: status
        },
        selected: false,
      }

      expect(subject).to include(status_option)
    end
  end

  it "returns filter options with the selected status" do
    subject = described_class.statuses("scheduled")

    all_option = {
      text: "All",
      data_attributes: {
        show: "all"
      },
      selected: false,
    }

    expect(subject).to include(all_option)

    scheduled_option = {
      text: "Scheduled",
      value: "scheduled",
      data_attributes: {
        show: "scheduled"
      },
      selected: true,
    }

    expect(subject).to include(scheduled_option)

    other_options = StepByStepPage::STATUSES.dup - %w(scheduled)

    other_options.each do |status|
      status_option = {
        text: status.humanize,
        value: status,
        data_attributes: {
          show: status
        },
        selected: false
      }

      expect(subject).to include(status_option)
    end
  end
end
