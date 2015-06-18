require 'rails_helper'

RSpec.describe MainstreamBrowsePagePresenter do

  describe "rendering for panopticon" do
    let(:mainstream_browse_page) { double(:mainstream_browse_page,
      slug: 'citizenship',
      title: 'Citizenship',
      description: 'Living in the UK, passports',
      parent: nil,
      legacy_tag_type: 'section',
    ) }

    let(:presenter) { MainstreamBrowsePagePresenter.new(mainstream_browse_page) }

    describe '#render_for_panopticon' do
      it 'sets the tag_type to "section"' do
        expect(presenter.render_for_panopticon[:tag_type]).to eq('section')
      end
    end
  end

  describe "rendering for publishing-api" do
    let(:browse_page) {
      create(:mainstream_browse_page, {
        :slug => 'benefits',
        :title => 'Benefits',
        :description => 'All about benefits',
      })
    }
    let(:presenter) { MainstreamBrowsePagePresenter.new(browse_page) }
    let(:presented_data) { presenter.render_for_publishing_api }

    it "returns the base_path for the browse page" do
      expect(presenter.base_path).to eq("/browse/benefits")
    end

    it "includes the base fields" do
      expect(presented_data).to include({
        :content_id => browse_page.content_id,
        :format => 'mainstream_browse_page',
        :title => 'Benefits',
        :description => 'All about benefits',
        :locale => 'en',
        :need_ids => [],
        :publishing_app => 'collections-publisher',
        :rendering_app => 'collections',
        :redirects => [],
        :update_type => "major",
        :details => { :groups=>[] },
      })
    end

    it "sets public_updated_at based on the browse page update time" do
      Timecop.travel 3.hours.ago do
        browse_page.touch
      end

      expect(presented_data[:public_updated_at]).to eq(browse_page.updated_at.iso8601)
    end

    it "includes the necessary routes" do
      expect(presented_data[:routes]).to eq([
        {:path => "/browse/benefits", :type => "exact"},
      ])
    end

    it "is valid against the schema", :schema_test => true do
      expect(presented_data).to be_valid_against_schema('mainstream_browse_page')
    end

    describe "linking to related topics" do
      let!(:parent_browse_page) { create(:mainstream_browse_page) }

      before :each do
        browse_page.update_attributes!(:parent => parent_browse_page)
      end

      context "without linked topics" do
        it "returns an empty array" do
          expect(presented_data[:links]["related_topics"]).to eq(
            []
          )
        end
      end

      context "with some linked topics" do
        let(:alpha) { create(:topic, :title => "Alpha") }
        let(:bravo) { create(:topic, :title => "Bravo") }

        before :each do
          browse_page.topics = [bravo, alpha]
          browse_page.save!
        end

        it "includes the content_ids of linked topics sorted by title" do
          expect(presented_data[:links]["related_topics"]).to eq([
            alpha.content_id,
            bravo.content_id,
          ])
        end

        it "is valid against the schema", :schema_test => true do
          expect(presented_data).to be_valid_against_schema('mainstream_browse_page')
        end
      end
    end

    describe "linking to related pages" do

      let!(:top_level_page_1) { create(
        :mainstream_browse_page,
        :title => "Top-level page 1",
      )}
      let!(:top_level_page_2) { create(
        :mainstream_browse_page,
        :title => "Top-level page 2",
      )}

      let!(:second_level_page_1) { create(
        :mainstream_browse_page,
        :title => "Second-level page 1",
        :parent => top_level_page_1,
      )}
      let!(:second_level_page_2) { create(
        :mainstream_browse_page,
        :title => "Second-level page 2",
        :parent => top_level_page_1,
      )}
      let!(:second_level_page_3) { create(
        :mainstream_browse_page,
        :title => "Second-level page 3",
        :parent => top_level_page_2,
      )}

      context "for a top-level browse page" do

        let(:presenter) { MainstreamBrowsePagePresenter.new(top_level_page_1) }
        let(:presented_data) { presenter.render_for_publishing_api }

        it "it has self as active browse page" do
          expect(presented_data[:links]["active_top_level_browse_page"]).to eq(
            [top_level_page_1.content_id]
          )
        end

        it "includes all the top-level browse pages" do
          expect(presented_data[:links]["top_level_browse_pages"]).to eq([
            top_level_page_1.content_id,
            top_level_page_2.content_id,
          ])
        end

        it "includes all the second-level child pages" do
          expect(presented_data[:links]["second_level_browse_pages"]).to eq([
            second_level_page_1.content_id,
            second_level_page_2.content_id,
          ])
        end

        it "is valid against the schema", :schema_test => true do
          expect(presented_data).to be_valid_against_schema('mainstream_browse_page')
        end
      end

      context "for a second-level browse page" do

        let(:presenter) { MainstreamBrowsePagePresenter.new(second_level_page_1) }
        let(:presented_data) { presenter.render_for_publishing_api }

        it "includes the parent top-level browse page" do
          expect(presented_data[:links]["active_top_level_browse_page"]).to eq([
            top_level_page_1.content_id
          ])
        end

        it "includes all the top-level browse pages" do
          expect(presented_data[:links]["top_level_browse_pages"]).to eq([
            top_level_page_1.content_id,
            top_level_page_2.content_id,
          ])
        end

        it "includes all its sibling second-level pages" do
          expect(presented_data[:links]["second_level_browse_pages"]).to eq([
            second_level_page_1.content_id,
            second_level_page_2.content_id,
          ])
        end

        it "is valid against the schema", :schema_test => true do
          expect(presented_data).to be_valid_against_schema('mainstream_browse_page')
        end
      end
    end
  end
end
