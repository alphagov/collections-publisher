require "rails_helper"

RSpec.describe StepByStepPageReverter do
  describe "#repopulate_from_publishing_api" do
    let(:step_by_step_page) { create(:step_by_step_page_with_navigation_rules, content_id: "content-id-of-step-by-step_by_step_nav") }

    subject { described_class.new(step_by_step_page, payload_from_publishing_api(step_by_step_page.content_id)) }

    before do
      allow(Services.publishing_api).to receive(:lookup_content_ids).and_return({})
      allow(Services.publishing_api).to receive(:get_content).with("42ce66de-04f3-4192-bf31-8394538e0734").and_return(
        secondary_content_item,
      )
      subject.repopulate_from_publishing_api
      step_by_step_page.reload
    end

    it "saves the title" do
      expect(step_by_step_page.title).to eq("An existing step by step that has previously been published")
    end

    it "saves the slug" do
      expect(step_by_step_page.slug).to eq("an-existing-step-by-step")
    end

    it "saves the introduction" do
      expect(step_by_step_page.introduction).to eq("An introduction to the step by step journey.")
    end

    it "saves the description" do
      expect(step_by_step_page.description).to eq("A description of the step by step page from publishing-api")
    end

    it "does not overwrite the content_id" do
      expect(step_by_step_page.content_id).to eq("content-id-of-step-by-step_by_step_nav")
    end

    it "does not change the created_at time" do
      created_at = Time.parse("2018-01-10T00:00:00Z")
      step_by_step = create(:step_by_step_page, created_at: created_at)

      updater = described_class.new(step_by_step, payload_from_publishing_api(step_by_step.content_id, base_path: "/base-path-1"))
      updater.repopulate_from_publishing_api

      step_by_step.reload
      expect(step_by_step.created_at).to eq(created_at)
    end

    it "does not change the published at time" do
      published_at = Time.parse("2018-01-10T00:00:00Z")
      step_by_step = create(:published_step_by_step_page, published_at: published_at)

      updater = described_class.new(step_by_step, payload_from_publishing_api(step_by_step.content_id, base_path: "/base-path-1"))
      updater.repopulate_from_publishing_api

      step_by_step.reload
      expect(step_by_step.published_at).to eq(published_at)
    end

    it "sets the draft_updated_at time to published_at time of the step by step" do
      published_at = Time.parse("2018-01-10T10:00:00Z")
      step_by_step = create(:published_step_by_step_page, published_at: published_at)

      updater = described_class.new(step_by_step, payload_from_publishing_api(step_by_step.content_id, base_path: "/base-path-1"))
      updater.repopulate_from_publishing_api

      step_by_step.reload
      expect(step_by_step.draft_updated_at).to eq(published_at)
    end

    it "sets the status to published" do
      expect(step_by_step_page.status).to be_published
    end

    describe "steps" do
      it "saves the right number of steps" do
        expect(step_by_step_page.steps.size).to eq(steps.size)
      end

      it "saves the step title for each step" do
        expect(step_by_step_page.steps[0].title).to eq("Step one of the step by step")
        expect(step_by_step_page.steps[1].title).to eq("Step two of the step by step")
        expect(step_by_step_page.steps[2].title).to eq("Step three of the step by step")
      end

      it "saves the logic for each step" do
        expect(step_by_step_page.steps[1].logic).to eq("number")
        expect(step_by_step_page.steps[2].logic).to eq("or")
        expect(step_by_step_page.steps[3].logic).to eq("and")
      end

      it "saves the position of the step" do
        expect(step_by_step_page.steps[0].position).to eq(1)
        expect(step_by_step_page.steps[1].position).to eq(2)
        expect(step_by_step_page.steps[2].position).to eq(3)
      end

      describe "#contents" do
        it "saves the contents of a paragraph" do
          expect(step_by_step_page.steps[0].contents).to eq(
            "A paragraph of text in the first step.\r\n\r\n" \
            "A second paragraph of text in the first step.",
          )
        end

        it "saves the contents of a list with links" do
          expect(step_by_step_page.steps[1].contents).to eq(
            "[The first item in the list for step two](/first-item-in-list-of-step-two)",
          )
        end

        it "saves the contents of a bulleted list with links" do
          expect(step_by_step_page.steps[2].contents).to eq(
            "- [The first item in the bulleted list for step three](/guidance/first-item-in-bulleted-list-of-step-three)",
          )
        end

        it "saves the contents of a bulleted list with just text" do
          expect(step_by_step_page.steps[4].contents).to eq(
            "- A list of text in the fifth step.",
          )
        end

        it "saves the contents of a list with links and context" do
          expect(step_by_step_page.steps[5].contents).to eq(
            "[The first item in the list for step six with context](/first-item-in-list-of-step-six-with-context) £23",
          )
        end

        it "saves the contents of a bulleted list with links and context" do
          expect(step_by_step_page.steps[6].contents).to eq(
            "- [The first item in the bulleted list for step seven with context](/first-item-in-list-of-step-seven-with-context) £62 to £75",
          )
        end

        it "saves a combination of links and paragraphs with context" do
          expect(step_by_step_page.steps[7].contents).to eq(
            "A paragraph of text in the eighth step.\r\n\r\n" \
            "A second paragraph of text in the eighth step.\r\n\r\n" \
            "[The first item in the list for step eight with context](/first-item-in-list-of-step-eight-with-context) £100\r\n" \
            "[The second item in the list for step eight](/second-item-in-list-of-step-eight)\r\n\r\n" \
            "A third paragraph of text in the eighth step.\r\n\r\n" \
            "- [The first item in the bulleted list for step eight with context](/first-item-in-bulleted-list-of-step-eight-with-context) £100\r\n" \
            "- [The second item in the bulleted list for step eight](/second-item-in-bulleted-list-of-step-eight)",
          )
        end
      end
    end

    describe "#navigation_rules" do
      before do
        allow(Services.publishing_api).to receive(:lookup_content_ids).with(
          base_paths: [
            "/first-item-in-list-of-step-two",
            "/guidance/first-item-in-bulleted-list-of-step-three",
            "/first-item-in-list-of-step-four",
            "/second-item-in-list-of-step-four",
            "/first-item-in-list-of-step-six-with-context",
            "/first-item-in-list-of-step-seven-with-context",
            "/first-item-in-list-of-step-eight-with-context",
            "/second-item-in-list-of-step-eight",
            "/first-item-in-bulleted-list-of-step-eight-with-context",
            "/second-item-in-bulleted-list-of-step-eight",
          ],
          with_drafts: true,
        ).and_return(
          "/first-item-in-list-of-step-two" => "a1156b8f-2a46-4fe1-8871-652abce9c925",
          "/guidance/first-item-in-bulleted-list-of-step-three" => "eca3f3dd-3296-4b86-8dc8-42f91fe0cb6e",
          "/first-item-in-list-of-step-four" => "8d35443d-7bf1-4f51-b9b1-e398e1d44030",
        )

        allow(Services.publishing_api).to receive(:get_content).with("a1156b8f-2a46-4fe1-8871-652abce9c925").and_return(
          "base_path" => "/first-item-in-list-of-step-two",
          "title" => "The first item in the list for step two",
          "content_id" => "a1156b8f-2a46-4fe1-8871-652abce9c925",
          "publishing_app" => "publisher",
          "rendering_app" => "frontend",
          "schema_name" => "transaction",
        )
        allow(Services.publishing_api).to receive(:get_content).with("eca3f3dd-3296-4b86-8dc8-42f91fe0cb6e").and_return(
          "base_path" => "/guidance/first-item-in-bulleted-list-of-step-three",
          "title" => "The first item in the bulleted list for step three",
          "content_id" => "eca3f3dd-3296-4b86-8dc8-42f91fe0cb6e",
          "publishing_app" => "publisher",
          "rendering_app" => "frontend",
          "schema_name" => "transaction",
        )
        allow(Services.publishing_api).to receive(:get_content).with("8d35443d-7bf1-4f51-b9b1-e398e1d44030").and_return(
          "base_path" => "/first-item-in-list-of-step-four",
          "title" => "The first item in the list for step four",
          "content_id" => "8d35443d-7bf1-4f51-b9b1-e398e1d44030",
          "publishing_app" => "publisher",
          "rendering_app" => "frontend",
          "schema_name" => "transaction",
        )

        updater = described_class.new(step_by_step_page, payload_from_publishing_api(step_by_step_page.content_id))
        updater.repopulate_from_publishing_api
        step_by_step_page.reload
      end

      it "saves the right number of navigation rules" do
        expect(step_by_step_page.navigation_rules.size).to eq(3)
      end

      it "saves the title of the rule" do
        titles = step_by_step_page.navigation_rules.pluck(:title)

        expect(titles).to include("The first item in the list for step two")
        expect(titles).to include("The first item in the bulleted list for step three")
        expect(titles).to include("The first item in the list for step four")
      end

      it "saves the base_path of the rule" do
        base_paths = step_by_step_page.navigation_rules.pluck(:base_path)

        expect(base_paths).to include("/first-item-in-list-of-step-two")
        expect(base_paths).to include("/guidance/first-item-in-bulleted-list-of-step-three")
        expect(base_paths).to include("/first-item-in-list-of-step-four")
      end

      it "saves the publishing_app of the rule" do
        step_by_step_page.navigation_rules.each do |rule|
          expect(rule.publishing_app).to eq("publisher")
        end
      end

      it "saves when to display the step nav" do
        navigation_rule1 = step_by_step_page.navigation_rules.find_by(base_path: "/first-item-in-list-of-step-two")
        expect(navigation_rule1.include_in_links).to eq("always")

        navigation_rule2 = step_by_step_page.navigation_rules.find_by(base_path: "/guidance/first-item-in-bulleted-list-of-step-three")
        expect(navigation_rule2.include_in_links).to eq("never")

        navigation_rule3 = step_by_step_page.navigation_rules.find_by(base_path: "/first-item-in-list-of-step-four")
        expect(navigation_rule3.include_in_links).to eq("conditionally")
      end
    end

    describe "#secondary_content" do
      it "saves the right number of secondary content" do
        expect(step_by_step_page.secondary_content_links.size).to eq(1)
      end

      it "saves the title of the secondary content" do
        title = step_by_step_page.secondary_content_links.first[:title]
        expect(title).to eq(secondary_content_item["title"])
      end

      it "saves the base_path of the secondary content" do
        base_path = step_by_step_page.secondary_content_links.first[:base_path]
        expect(base_path).to eq(secondary_content_item["base_path"])
      end

      it "saves the publishing_app of the secondary content" do
        publishing_app = step_by_step_page.secondary_content_links.first[:publishing_app]
        expect(publishing_app).to eq(secondary_content_item["publishing_app"])
      end

      it "saves the schema_name of the secondary content" do
        schema_name = step_by_step_page.secondary_content_links.first[:schema_name]
        expect(schema_name).to eq(secondary_content_item["schema_name"])
      end
    end
  end

  def payload_from_publishing_api(content_id, base_path: "/an-existing-step-by-step")
    {
      "base_path": base_path,
      "content_store": "live",
      "description": "A description of the step by step page from publishing-api",
      "details": {
        "step_by_step_nav": {
          "title": "An existing step by step that has previously been published",
          "introduction": [
            {
              "content_type": "text/govspeak",
              "content": "An introduction to the step by step journey.",
            },
          ],
          "steps": [
            {
              "title": "Step one of the step by step",
              "contents": [
                {
                  "type": "paragraph",
                  "text": "A paragraph of text in the first step.",
                },
                {
                  "type": "paragraph",
                  "text": "A second paragraph of text in the first step.",
                },
              ],
            },
            {
              "title": "Step two of the step by step",
              "contents": [
                {
                  "type": "list",
                  "contents": [
                    {
                      "text": "The first item in the list for step two",
                      "href": "/first-item-in-list-of-step-two",
                    },
                  ],
                },
              ],
            },
            {
              "title": "Step three of the step by step",
              "contents": [
                {
                  "type": "list",
                  "style": "choice",
                  "contents": [
                    {
                      "text": "The first item in the bulleted list for step three",
                      "href": "/guidance/first-item-in-bulleted-list-of-step-three",
                    },
                  ],
                },
              ],
              "logic": "or",
            },
            {
              "title": "Step four of the step by step",
              "contents": [
                {
                  "type": "list",
                  "contents": [
                    {
                      "text": "The first item in the list for step four",
                      "href": "/first-item-in-list-of-step-four",
                    },
                    {
                      "text": "The second item in the list for step four",
                      "href": "/second-item-in-list-of-step-four",
                    },
                    {
                      "text": "The third item in the list for step four",
                      "href": "https://www.external.link/third-item-in-list-of-step-four",
                    },
                  ],
                },
              ],
              "logic": "and",
            },
            {
              "title": "Step five of the step by step",
              "contents": [
                {
                  "type": "list",
                  "style": "choice",
                  "contents": [
                    {
                      "text": "A list of text in the fifth step.",
                    },
                  ],
                },
              ],
            },
            {
              "title": "Step six of the step by step",
              "contents": [
                {
                  "type": "list",
                  "contents": [
                    {
                      "text": "The first item in the list for step six with context",
                      "href": "/first-item-in-list-of-step-six-with-context",
                      "context": "£23",
                    },
                  ],
                },
              ],
            },
            {
              "title": "Step seven of the step by step",
              "contents": [
                {
                  "type": "list",
                  "style": "choice",
                  "contents": [
                    {
                      "text": "The first item in the bulleted list for step seven with context",
                      "href": "/first-item-in-list-of-step-seven-with-context",
                      "context": "£62 to £75",
                    },
                  ],
                },
              ],
            },
            {
              "title": "Step eight of the step by step",
              "contents": [
                {
                  "type": "paragraph",
                  "text": "A paragraph of text in the eighth step.",
                },
                {
                  "type": "paragraph",
                  "text": "A second paragraph of text in the eighth step.",
                },
                {
                  "type": "list",
                  "contents": [
                    {
                      "text": "The first item in the list for step eight with context",
                      "href": "/first-item-in-list-of-step-eight-with-context",
                      "context": "£100",
                    },
                    {
                      "text": "The second item in the list for step eight",
                      "href": "/second-item-in-list-of-step-eight",
                    },
                  ],
                },
                {
                  "type": "paragraph",
                  "text": "A third paragraph of text in the eighth step.",
                },
                {
                  "type": "list",
                  "style": "choice",
                  "contents": [
                    {
                      "text": "The first item in the bulleted list for step eight with context",
                      "href": "/first-item-in-bulleted-list-of-step-eight-with-context",
                      "context": "£100",
                    },
                    {
                      "text": "The second item in the bulleted list for step eight",
                      "href": "/second-item-in-bulleted-list-of-step-eight",
                    },
                  ],
                },
              ],
            },
          ],
        },
      },
      "document_type": "step_by_step_nav",
      "first_published_at": "2017-11-01T15:31:15Z",
      "last_edited_at": "2018-08-31T11:07:06Z",
      "phase": "live",
      "public_updated_at": "2018-08-31T10:58:30Z",
      "publishing_app": "collections-publisher",
      "redirects": [],
      "rendering_app": "collections",
      "routes": [
        {
          "path": "/an-existing-step-by-step",
          "type": "exact",
        },
      ],
      "schema_name": "step_by_step_nav",
      "title": "An existing step by step that has previously been published",
      "user_facing_version": 7,
      "update_type": "minor",
      "publication_state": "published",
      "content_id": content_id,
      "locale": "en",
      "lock_version": 20,
      "updated_at": "2018-08-31 11:07:06.977105",
      "state_history": {
        "5": "superseded",
        "6": "published",
        "1": "superseded",
        "2": "superseded",
        "3": "superseded",
        "4": "superseded",
      },
      "links": {
        "pages_related_to_step_nav": %w(
          8d35443d-7bf1-4f51-b9b1-e398e1d44030
        ),
        "pages_part_of_step_nav": %w(
          a1156b8f-2a46-4fe1-8871-652abce9c925
          45c23180-968a-47bb-adbc-25d5422015ff
          d6b1901d-b925-47c5-b1ca-1e52197097e2
          b5d8c773-3a31-45f2-838d-255afef5511a
          bbf6c11a-7dc6-4fe6-8dd8-68c09bdbe562
          1788c387-8680-4454-8923-71ad0f632cbb
          2b422e36-85c4-40fb-a40b-5cd40c86c0f8
          2148f116-f909-4976-bb05-cb4899f3272a
        ),
        "pages_secondary_to_step_nav": %w(
          42ce66de-04f3-4192-bf31-8394538e0734
        ),
      },
      "warnings": {
      },
    }
  end

  def steps
    @payload ||= payload_from_publishing_api(step_by_step_page.content_id)
    @payload[:details][:step_by_step_nav][:steps]
  end

  def secondary_content_item
    {
      "base_path" => "/guidance/thats-sort-or-relevant",
      "title" => "Guidance that's sort of relevant",
      "content_id" => "42ce66de-04f3-4192-bf31-8394538e0734",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "schema_name" => "transaction",
    }
  end
end
