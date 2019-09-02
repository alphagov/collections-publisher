require "rails_helper"
require "gds_api/test_helpers/link_checker_api"

RSpec.describe StepByStepPagePresenter do
  include TimeOptionsHelper

  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  describe "#summary_list" do
    let(:time_now) { Time.zone.now }
    let(:step_nav) { create(:draft_step_by_step_page) }
    let(:default_summary) {
      {
        "Status" => "Draft",
        "Last saved" => format_full_date_and_time(time_now),
        "Created" => format_full_date_and_time(time_now)
      }
    }

    subject { described_class.new(step_nav).summary_metadata }

    it "presents a list of key/value metadata" do
      expect(subject).to eq(default_summary)
    end

    it "shows who made the most recent change" do
      step_nav.assigned_to = "Firstname Lastname"

      expect(subject["Last saved"]).to eq("#{format_full_date_and_time(time_now)} by #{step_nav.assigned_to}")
    end

    it "has additional metadata showing when links were checked" do
      create(:link_report, step: step_nav.steps.first)
      summary_with_links_checked = default_summary.merge(
        "Links checked" => format_full_date_and_time(time_now)
      )

      expect(subject).to eq(summary_with_links_checked)
    end
  end
end
