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

    describe "#access_limited" do
      before do
        allow(step_nav).to receive(:auth_bypass_id) { "123" }
      end

      it "adds an access limiting token to drafts" do
        step_nav.mark_draft_updated

        presented = subject.render_for_publishing_api
        expected_access_limited_tokens = {
          auth_bypass_ids: ["123"]
        }

        expect(presented[:access_limited]).to eq(expected_access_limited_tokens)
      end

      it "doesn't add an access limiting token when publishing" do
        step_nav.mark_as_published

        presented = subject.render_for_publishing_api

        expect(presented[:access_limited]).to be nil
      end
    end

    describe "smartanswers" do
      before do
        allow(Services.publishing_api).to receive(:lookup_content_id)
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return('/a-smartanswer/y' => '2fcc4688-89b5-4e71-802d-d95c69fe458a')
      end

      let(:step_nav_with_smartanswer) { create(:step_by_step_page_with_smartanswer_navigation_rules) }
      subject { described_class.new(step_nav_with_smartanswer) }

      it "adds the content_id of the smartanswer done page to pages_part_of_step_nav" do
        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_part_of_step_nav].count).to eq(3)
        expect(presented[:links][:pages_part_of_step_nav]).to include('2fcc4688-89b5-4e71-802d-d95c69fe458a')
      end

      it "doesn't add the content_id of the smartanswer done page if include_in_links is false" do
        rule = step_nav_with_smartanswer.navigation_rules.select(&:smartanswer?).first
        rule.include_in_links = false
        rule.save

        step_nav_with_smartanswer.reload
        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_part_of_step_nav].count).to eq(1)
        expect(presented[:links][:pages_related_to_step_nav].count).to eq(1)
      end
    end
  end
end
