require 'rails_helper'

RSpec.describe StepNavPresenter do
  include GovukContentSchemaTestHelpers

  describe "#render_for_publishing_api" do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    let(:step_nav) { create(:step_by_step_page_with_navigation_rules) }

    subject { described_class.new(step_nav) }

    before do
      allow(StepNavPublisher).to receive(:lookup_content_ids).and_return('/foo' => 'd6b1901d-b925-47c5-b1ca-1e52197097e2')
    end

    it "presents a step by step page in the correct format" do
      presented = subject.render_for_publishing_api
      expect(presented).to be_valid_against_schema("step_by_step_nav")

      expect(presented[:update_type]).to eq("minor")
      expect(presented[:base_path]).to eq("/how-to-be-the-amazing-1")
      expect(presented[:routes]).to eq([{ path: "/how-to-be-the-amazing-1", type: "exact" }])
    end

    it "copes with optional properties" do
      presented = subject.render_for_publishing_api
      steps = presented[:details][:step_by_step_nav][:steps]

      expect(steps[0][:optional]).to be false
      expect(steps[1][:optional]).to be true

      expect(steps[0][:logic]).to be nil
      expect(steps[1][:logic]).to eq "or"
    end

    it "presents edition links correctly" do
      presented = subject.render_for_publishing_api
      expect(presented[:links][:pages_part_of_step_nav].count).to eq(2)
      expect(presented[:links][:pages_related_to_step_nav]).to be nil
    end

    it "detects pages for navigation" do
      step_nav_with_navigation = create(:step_by_step_page_with_navigation_rules)
      rule1 = step_nav_with_navigation.navigation_rules.first
      rule1.include_in_links = false
      rule1.save

      step_nav_with_navigation.reload

      presenter = described_class.new(step_nav_with_navigation)
      presented = presenter.render_for_publishing_api

      expect(presented[:links][:pages_part_of_step_nav].count).to eq(1)
      expect(presented[:links][:pages_related_to_step_nav].count).to eq(1)
    end

    it "shows the correct update type and change note" do
      intent = PublishIntent.new(update_type: "major", change_note: "All your update belong to us")
      presented = subject.render_for_publishing_api(intent)

      expect(presented).to be_valid_against_schema("step_by_step_nav")
      expect(presented[:update_type]).to eq("major")
      expect(presented[:change_note]).to eq("All your update belong to us")
    end
  end
end
