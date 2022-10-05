require "rails_helper"

RSpec.describe StepLinksForRules do
  include StepLinkFixtures

  let(:step_page) { create(:step_by_step_page_with_steps) }
  let(:first_step) { step_page.steps.first }
  let(:base_paths) { step_link_fixtures_return_data.keys }

  before do
    publishing_api_receives_request_to_lookup_content_id(
      base_path: "/how-to-be-the-amazing-1",
    )
  end

  context "when a step page has no rules" do
    it "has no navigation rules" do
      expect(step_page.navigation_rules.count).to eql(0)
    end

    it "adds new navigation rules alphabetically" do
      setup_test_with_publishing_api_requests

      described_class.new(step_by_step_page: step_page).call

      navigation_rules = step_page.reload.navigation_rules

      expect(navigation_rules.size).to eql(3)

      expect(navigation_rules.first.title).to eq("Also Good Stuff")
      expect(navigation_rules.second.title).to eq("Good Stuff")
      expect(navigation_rules.third.title).to eq("Not as Great")
    end
  end

  context "when a step page has rules" do
    before do
      setup_test_with_publishing_api_requests
      described_class.new(step_by_step_page: step_page).call
    end

    it "has 3 rules" do
      expect(
        step_page.navigation_rules.size,
      ).to eql(3)
    end

    context "and there are new links added to the content" do
      it "adds the missing rules" do
        first_step.contents << "\n[An Amazing Magic Link](/amazing-magic-link)"
        first_step.save!

        base_path_data = {
          "/amazing-magic-link" => "fd6b1901d-A747-47c5-b1ca-1e52197097e3",
        }

        amazing_content_item = basic_content_item(
          title: "An Amazing Magic Link",
          base_path: base_path_data.keys.first,
          content_id: base_path_data.values.first,
          publishing_app: "publisher",
          schema_name: "guide",
        )

        publishing_api_receives_request_to_lookup_content_ids(
          base_paths: base_paths << base_path_data.keys.first,
          return_data: step_link_fixtures_return_data.merge(base_path_data),
        )

        publishing_api_receives_get_content_id_request(
          content_items: step_link_fixtures_content_items << amazing_content_item,
        )

        described_class.new(step_by_step_page: step_page).call

        expect(
          step_page.navigation_rules.size,
        ).to eql(4)
      end

      it "keeps the state of the existing rules" do
        rule = step_page.navigation_rules.first
        rule_content_id = rule.content_id

        rule.update!(include_in_links: "conditionally")
        expect(rule.reload.include_in_links).to eq("conditionally")

        publishing_api_receives_request_to_lookup_content_ids(
          base_paths:,
          return_data: step_link_fixtures_return_data,
        )

        publishing_api_receives_get_content_id_request(
          content_items: step_link_fixtures_content_items,
        )

        described_class.new(step_by_step_page: step_page).call

        expect { rule.reload }.to raise_error ActiveRecord::RecordNotFound

        new_rule = NavigationRule.find_by(content_id: rule_content_id)
        expect(new_rule.include_in_links).to eq("conditionally")
      end
    end

    context "when the links are removed from the content" do
      it "removes the rules for those links" do
        first_step.update!(contents: "Hello World")
        second_step = step_page.steps.second

        second_step.update!(contents: "This is a great step\n\n- [Good stuff](/good/stuff)")

        publishing_api_receives_request_to_lookup_content_ids(
          base_paths: [base_paths.first],
          return_data: {
            "/good/stuff" => "fd6b1901d-b925-47c5-b1ca-1e52197097e1",
          },
        )

        publishing_api_receives_get_content_id_request(
          content_items: [step_link_fixtures_content_items.first],
        )

        expect(
          step_page.navigation_rules.count,
        ).to eql(3)

        described_class.new(step_by_step_page: step_page).call

        expect(
          step_page.navigation_rules.count,
        ).to eql(1)
      end
    end
  end

  def setup_test_with_publishing_api_requests
    publishing_api_receives_request_to_lookup_content_ids(
      base_paths: step_link_fixtures_return_data.keys,
      return_data: step_link_fixtures_return_data,
    )

    publishing_api_receives_get_content_id_request(
      content_items: step_link_fixtures_content_items,
    )
  end
end
