require "rails_helper"

RSpec.describe StepNavPresenter do
  describe "#render_for_publishing_api" do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    let(:step_nav) { create(:step_by_step_page_with_navigation_rules) }

    subject { described_class.new(step_nav) }

    before do
      allow(StepNavPublisher).to receive(:lookup_content_ids).and_return([])
    end

    it "presents a step by step page in the correct format" do
      presented = subject.render_for_publishing_api
      expect(presented).to be_valid_against_publisher_schema("step_by_step_nav")

      expect(presented[:update_type]).to eq("minor")
      expect(presented[:base_path]).to eq("/how-to-be-the-amazing-1")
      expect(presented[:routes]).to eq([{ path: "/how-to-be-the-amazing-1", type: "exact" }])
    end

    it "includes an html representation of the page so that it may be indexed in search" do
      presented = subject.render_for_publishing_api
      expected = <<~BODY
        <h2>Check how awesome you are</h2>

        <p>This is a great step</p>

        <ul>
          <li><a href="/good/stuff">Good stuff</a></li>
          <li>
            <p><a href="/also/good/stuff">Also good stuff</a></p>
          </li>
          <li><a href="/not/as/great">Not as great</a>£25</li>
          <li><a href="http://example.com/good">But good nonetheless</a></li>
        </ul>


        <h2>Dress like the Fonz</h2>

        <p>This is another great step</p>
      BODY

      expect(presented).to be_valid_against_publisher_schema("step_by_step_nav")
      expect(presented[:details][:body]).to eq(expected)
    end

    it "presents edition links correctly" do
      presented = subject.render_for_publishing_api
      expect(presented[:links][:pages_part_of_step_nav].count).to eq(2)
      expect(presented[:links][:pages_related_to_step_nav]).to be nil
    end

    it "detects pages for navigation" do
      step_nav_with_navigation = create(:step_by_step_page_with_navigation_rules)
      rule1 = step_nav_with_navigation.navigation_rules.first
      rule1.include_in_links = "conditionally"
      rule1.save!

      step_nav_with_navigation.reload

      presenter = described_class.new(step_nav_with_navigation)
      presented = presenter.render_for_publishing_api

      expect(presented[:links][:pages_part_of_step_nav].count).to eq(1)
      expect(presented[:links][:pages_related_to_step_nav].count).to eq(1)
    end

    it "shows the correct update type and change note" do
      intent = PublishIntent.new(update_type: "major", change_note: "All your update belong to us")
      presented = subject.render_for_publishing_api(intent)

      expect(presented).to be_valid_against_publisher_schema("step_by_step_nav")
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
        expected_auth_bypass_ids = %w[123]

        expect(presented[:auth_bypass_ids]).to eq(expected_auth_bypass_ids)
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
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return("/a-smartanswer/y" => "2fcc4688-89b5-4e71-802d-d95c69fe458a")
      end

      let(:step_nav_with_smartanswer) { create(:step_by_step_page_with_smartanswer_navigation_rules) }
      subject { described_class.new(step_nav_with_smartanswer) }

      it "adds the content_id of the smartanswer done page to pages_part_of_step_nav" do
        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_part_of_step_nav].count).to eq(3)
        expect(presented[:links][:pages_part_of_step_nav]).to include("2fcc4688-89b5-4e71-802d-d95c69fe458a")
      end

      it "doesn't add the content_id of the smartanswer done page if include_in_links is 'conditionally'" do
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return([])

        rule = step_nav_with_smartanswer.navigation_rules.select(&:smartanswer?).first
        rule.include_in_links = "conditionally"
        rule.save!

        step_nav_with_smartanswer.reload
        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_part_of_step_nav].count).to eq(1)
        expect(presented[:links][:pages_related_to_step_nav].count).to eq(1)
      end
    end

    describe "service done pages" do
      it "adds the content_id of the service done page to pages_part_of_step_nav" do
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return("/done/good/stuff" => "cd47dd79-393f-4ead-9c1c-c85e3f1b3423")

        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_part_of_step_nav].count).to eq(3)
        expect(presented[:links][:pages_part_of_step_nav]).to include("cd47dd79-393f-4ead-9c1c-c85e3f1b3423")
      end

      it "doesn't add the content_id of the service done page if include_in_links is 'conditionally'" do
        rule = step_nav.navigation_rules.first
        rule.include_in_links = "conditionally"
        rule.save!

        step_nav.reload
        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_part_of_step_nav].count).to eq(1)
        expect(presented[:links][:pages_related_to_step_nav].count).to eq(1)
      end
    end

    describe "secondary content" do
      let(:step_nav_with_secondary_content) { create(:step_by_step_page_with_secondary_content, slug: "step-nav-with-secondary-content") }

      subject { described_class.new(step_nav_with_secondary_content) }

      before do
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return([])
      end

      it "adds the content_id of secondary content to pages_secondary_to_step_nav" do
        presented = subject.render_for_publishing_api

        expect(presented[:links][:pages_secondary_to_step_nav].count).to eq(1)
      end

      it "adds the content id of the smartanswer done page to pages_secondary_to_step_nav" do
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return("/a-smartanswer/y" => "2fcc4688-89b5-4e71-802d-d95c69fe458a")

        build(
          :secondary_content_link,
          step_by_step_page: step_nav,
          base_path: "/a-smartanswer",
          publishing_app: "smartanswers",
          schema_name: "transaction",
        )

        presented = subject.render_for_publishing_api
        expect(presented[:links][:pages_secondary_to_step_nav].count).to eq(2)
        expect(presented[:links][:pages_secondary_to_step_nav]).to include("2fcc4688-89b5-4e71-802d-d95c69fe458a")
      end

      it "adds the content id of a service done page to pages_secondary_to_step_nav" do
        allow(StepNavPublisher).to receive(:lookup_content_ids).and_return("/done/service-start-page" => "2fcc4688-89b5-4e71-802d-d95c69fe458a")

        build(
          :secondary_content_link,
          step_by_step_page: step_nav,
          base_path: "/service-start-page",
          publishing_app: "publisher",
          schema_name: "transaction",
        )

        presented = subject.render_for_publishing_api
        expect(presented[:links][:pages_secondary_to_step_nav].count).to eq(2)
        expect(presented[:links][:pages_secondary_to_step_nav]).to include("2fcc4688-89b5-4e71-802d-d95c69fe458a")
      end
    end
  end

  describe "#scheduling_payload" do
    let(:step_nav) { create(:draft_step_by_step_page, scheduled_at: Date.tomorrow) }

    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    subject { described_class.new(step_nav) }

    it "adds the scheduled_at time" do
      presented = subject.scheduling_payload
      expect(presented[:publish_time]).to eq(step_nav.scheduled_at)
    end

    it "adds the publishing app" do
      presented = subject.scheduling_payload
      expect(presented[:publishing_app]).to eq("collections-publisher")
    end

    it "adds the rendering_app" do
      presented = subject.scheduling_payload
      expect(presented[:rendering_app]).to eq("collections")
    end
  end

  describe "#base_path" do
    let(:step_nav) { create(:step_by_step_page) }

    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    subject { described_class.new(step_nav) }

    it "gets the base_path" do
      expect(subject.base_path).to eq("/how-to-be-the-amazing-1")
    end
  end
end
