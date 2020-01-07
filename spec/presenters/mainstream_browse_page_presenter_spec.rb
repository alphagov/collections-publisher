require "rails_helper"

RSpec.describe MainstreamBrowsePagePresenter do
  describe "#links" do
    it "includes the parent in the links" do
      browse_page = create(
        :mainstream_browse_page,
        parent: create(:mainstream_browse_page, content_id: "9bb05887-d741-4a98-95b2-2c45dfc31556"),
      )

      presenter = MainstreamBrowsePagePresenter.new(browse_page)

      expect(
        presenter.render_links_for_publishing_api[:links]["parent"],
      ).to eql(%w(9bb05887-d741-4a98-95b2-2c45dfc31556))
    end
  end

  describe "rendering for publishing-api" do
    let(:browse_page) {
      create(:mainstream_browse_page, slug: "benefits",
        title: "Benefits",
        description: "All about benefits")
    }
    let(:presenter) { MainstreamBrowsePagePresenter.new(browse_page) }
    let(:presented_data) { presenter.render_for_publishing_api }

    it "returns the base_path for the browse page" do
      expect(presenter.base_path).to eq("/browse/benefits")
    end

    it "includes the base fields" do
      expect(presented_data).to include(schema_name: "mainstream_browse_page",
        document_type: "mainstream_browse_page",
        title: "Benefits",
        description: "All about benefits",
        locale: "en",
        publishing_app: "collections-publisher",
        rendering_app: "collections",
        redirects: [])
    end

    it "sets public_updated_at based on the browse page update time" do
      Timecop.travel 3.hours.ago do
        browse_page.touch
      end

      expect(presented_data[:public_updated_at]).to eq(browse_page.updated_at.iso8601)
    end

    it "includes the necessary routes" do
      expect(presented_data[:routes]).to eq([
        { path: "/browse/benefits", type: "exact" },
        { path: "/browse/benefits.json", type: "exact" },
      ])
    end

    it "is valid against the schema" do
      expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
    end

    describe "linking to related topics" do
      let!(:parent_browse_page) { create(:mainstream_browse_page) }
      let(:rendered_links)      { presenter.render_links_for_publishing_api }

      before :each do
        browse_page.update!(parent: parent_browse_page)
      end

      context "without linked topics" do
        it "returns an empty array" do
          expect(rendered_links[:links]["related_topics"]).to eq(
            [],
          )
        end
      end

      context "with some linked topics" do
        let(:alpha) { create(:topic, title: "Alpha") }
        let(:bravo) { create(:topic, title: "Bravo") }

        before :each do
          browse_page.topics = [bravo, alpha]
          browse_page.save!
        end

        it "includes the content_ids of linked topics sorted by title" do
          expect(rendered_links[:links]["related_topics"]).to eq([
            alpha.content_id,
            bravo.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end
    end

    describe "linking to primary publishing organisation" do
      let!(:parent_browse_page) { create(:mainstream_browse_page) }
      let(:rendered_links)      { presenter.render_links_for_publishing_api }
      let(:organisation) { "af07d5a5-df63-4ddc-9383-6a666845ebe9" }

      before :each do
        browse_page.update!(parent: parent_browse_page)
      end

      it "includes Government Digital Service content id" do
        expect(rendered_links[:links]["primary_publishing_organisation"]).to eq([organisation])
      end
    end

    describe "linking to related pages" do
      let!(:top_level_page_1) {
        create(
          :mainstream_browse_page,
          title: "Top-level page 1",
          child_ordering: "alphabetical",
      )
      }
      let!(:top_level_page_2) {
        create(
          :mainstream_browse_page,
          title: "Top-level page 2",
          child_ordering: "curated",
      )
      }

      let!(:second_level_page_B) {
        create(
          :mainstream_browse_page,
          title: "Second-level page B",
          parent: top_level_page_1,
      )
      }
      let!(:second_level_page_A) {
        create(
          :mainstream_browse_page,
          title: "Second-level page A",
          parent: top_level_page_1,
      )
      }

      let!(:second_level_page_C) {
        create(
          :mainstream_browse_page,
          title: "Second-level page C",
          parent: top_level_page_2,
          index: 1,
      )
      }
      let!(:second_level_page_D) {
        create(
          :mainstream_browse_page,
          title: "Second-level page D",
          parent: top_level_page_2,
          index: 0,
      )
      }

      context "for a top-level browse page with children in alphabetical order" do
        let(:presenter) { MainstreamBrowsePagePresenter.new(top_level_page_1) }
        let(:rendered_links) { presenter.render_links_for_publishing_api }

        it "it has self as active browse page" do
          expect(rendered_links[:links]["active_top_level_browse_page"]).to eq(
            [top_level_page_1.content_id],
          )
        end

        it "includes all the top-level browse pages" do
          expect(rendered_links[:links]["top_level_browse_pages"]).to eq([
            top_level_page_1.content_id,
            top_level_page_2.content_id,
          ])
        end

        it "includes, in alphabetical order, all the second-level child pages" do
          expect(rendered_links[:links]["second_level_browse_pages"]).to eq([
            second_level_page_A.content_id,
            second_level_page_B.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end

      context "for a top-level browse page with children in curated order" do
        let(:presenter) { MainstreamBrowsePagePresenter.new(top_level_page_2) }
        let(:rendered_links) { presenter.render_links_for_publishing_api }

        it "includes, in curated order, all the second-level child pages" do
          expect(rendered_links[:links]["second_level_browse_pages"]).to eq([
            second_level_page_D.content_id,
            second_level_page_C.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end

      context "for an alphabetically ordered second-level browse page" do
        let(:presenter) { MainstreamBrowsePagePresenter.new(second_level_page_A) }
        let(:rendered_links) { presenter.render_links_for_publishing_api }

        it "includes the parent top-level browse page" do
          expect(rendered_links[:links]["active_top_level_browse_page"]).to eq([
            top_level_page_1.content_id,
          ])
        end

        it "includes all the top-level browse pages" do
          expect(rendered_links[:links]["top_level_browse_pages"]).to eq([
            top_level_page_1.content_id,
            top_level_page_2.content_id,
          ])
        end

        it "includes, in alphabetical order, all its sibling second-level pages" do
          expect(rendered_links[:links]["second_level_browse_pages"]).to eq([
            second_level_page_A.content_id,
            second_level_page_B.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end

      context "for an customly ordered second-level browse page" do
        let(:presenter) { MainstreamBrowsePagePresenter.new(second_level_page_C) }
        let(:rendered_links) { presenter.render_links_for_publishing_api }
        let(:presented_data) { presenter.render_for_publishing_api }

        it "includes, in curated order, all its sibling second-level pages" do
          expect(rendered_links[:links]["second_level_browse_pages"]).to eq([
            second_level_page_D.content_id,
            second_level_page_C.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end
    end

    describe "returning the order of relative second level browse pages" do
      let!(:top_level_page) {
        create(
          :mainstream_browse_page,
          title: "Top-level page",
          child_ordering: "curated",
      )
      }

      let!(:second_level_page_1) {
        create(
          :mainstream_browse_page,
          title: "Second-level page",
          parent: top_level_page,
      )
      }

      let!(:second_level_page_2) {
        create(
          :mainstream_browse_page,
          title: "Another second-level page",
          parent: top_level_page,
      )
      }

      context "for a top level page" do
        let(:presenter) { MainstreamBrowsePagePresenter.new(top_level_page) }
        let(:presented_data) { presenter.render_for_publishing_api }

        it "returns the order in which its children are ordered" do
          expect(presented_data[:details]["second_level_ordering"]).to eq("curated")
          expect(presented_data[:details]["ordered_second_level_browse_pages"]).to eq([
            second_level_page_1.content_id,
            second_level_page_2.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end

      context "for a second level page" do
        let(:presenter) { MainstreamBrowsePagePresenter.new(second_level_page_1) }
        let(:presented_data) { presenter.render_for_publishing_api }

        it "returns the order in which self and its siblings are ordered" do
          expect(presented_data[:details]["second_level_ordering"]).to eq("curated")
          expect(presented_data[:details]["ordered_second_level_browse_pages"]).to eq([
            second_level_page_1.content_id,
            second_level_page_2.content_id,
          ])
        end

        it "is valid against the schema" do
          expect(presented_data).to be_valid_against_schema("mainstream_browse_page")
        end
      end
    end
  end
end
