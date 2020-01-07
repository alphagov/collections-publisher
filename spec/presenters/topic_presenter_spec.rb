require "rails_helper"

RSpec.describe TopicPresenter do
  describe "rendering for publishing-api" do
    context "for a top-level topic" do
      let(:topic) {
        create(:topic, slug: "working-at-sea",
          title: "Working at sea",
          description: "The sea, the sky, the sea, the sky...")
      }
      let(:presenter) { TopicPresenter.new(topic) }
      let(:presented_data) { presenter.render_for_publishing_api }
      let(:rendered_links) { presenter.render_links_for_publishing_api }

      it "includes the base fields" do
        expect(presented_data).to include(schema_name: "topic",
          document_type: "topic",
          title: "Working at sea",
          description: "The sea, the sky, the sea, the sky...",
          locale: "en",
          publishing_app: "collections-publisher",
          rendering_app: "collections",
          redirects: [])
      end

      it "is valid against the schema" do
        expect(presented_data).to be_valid_against_schema("topic")
      end

      it "returns the base_path for the topic" do
        expect(presenter.base_path).to eq("/topic/working-at-sea")
      end

      it "sets public_updated_at based on the topic update time" do
        the_past = 3.hours.ago
        Timecop.freeze the_past do
          topic.touch
        end
        expect(presented_data[:public_updated_at]).to eq(the_past.iso8601)
      end

      it "includes the base route" do
        expect(presented_data[:routes]).to eq([
          { path: "/topic/working-at-sea", type: "exact" },
        ])
      end

      describe "links" do
        it "does not include a parent link" do
          expect(rendered_links[:links]).not_to have_key("parent")
        end

        it "includes links to all its child topics in title order" do
          bravo = create(:topic, parent: topic, title: "Bravo")
          alpha = create(:topic, parent: topic, title: "Alpha")
          expect(rendered_links[:links]).to have_key("children")
          expect(rendered_links[:links]["children"]).to eq([alpha, bravo].map(&:content_id))
        end

        it "includes links to primary publishing organisation" do
          organisation = "af07d5a5-df63-4ddc-9383-6a666845ebe9"
          expect(rendered_links[:links]).to have_key("primary_publishing_organisation")
          expect(rendered_links[:links]["primary_publishing_organisation"]).to eq([organisation])
        end
      end
    end

    context "for a subtopic" do
      let(:parent) { create(:topic, slug: "oil-and-gas") }
      let(:topic) {
        create(:topic, parent: parent,
          slug: "offshore",
          title: "Offshore",
          description: "Oil rigs, pipelines etc.")
      }
      let(:presenter) { TopicPresenter.new(topic) }
      let(:presented_data) { presenter.render_for_publishing_api }
      let(:rendered_links) { presenter.render_links_for_publishing_api }

      it "returns the base_path for the subtopic" do
        expect(presenter.base_path).to eq("/topic/oil-and-gas/offshore")
      end

      it "includes the base fields" do
        expect(presented_data).to include(schema_name: "topic",
          document_type: "topic",
          title: "Offshore",
          description: "Oil rigs, pipelines etc.",
          locale: "en",
          publishing_app: "collections-publisher",
          rendering_app: "collections",
          redirects: [])
      end

      it "is valid against the schema" do
        expect(presented_data).to be_valid_against_schema("topic")
      end

      it "sets public_updated_at based on the topic update time" do
        the_past = 3.hours.ago
        Timecop.freeze the_past do
          topic.touch
        end
        expect(presented_data[:public_updated_at]).to eq(the_past.iso8601)
      end

      it "includes routes for latest, and email_signups in addition to base route" do
        expect(presented_data[:routes]).to eq([
          { path: "/topic/oil-and-gas/offshore", type: "exact" },
          { path: "/topic/oil-and-gas/offshore/latest", type: "exact" },
          { path: "/topic/oil-and-gas/offshore/email-signup", type: "exact" },
        ])
      end

      it "includes a link to its parent" do
        expect(rendered_links[:links]).to have_key("parent")
        expect(rendered_links[:links]["parent"]).to eq([parent.content_id])
      end
    end
  end
end
