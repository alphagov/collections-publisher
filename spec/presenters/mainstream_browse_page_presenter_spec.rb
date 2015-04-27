require 'spec_helper'

describe MainstreamBrowsePagePresenter do

  describe "rendering for panopticon" do
    let(:mainstream_browse_page) { double(:mainstream_browse_page,
      slug: 'citizenship',
      title: 'Citizenship',
      description: 'Living in the UK, passports',
      parent: nil,
      tag_type: 'section',
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
      page = build(:mainstream_browse_page, {
        :slug => 'benefits',
        :title => 'Benefits',
        :description => 'All about benefits',
      })
      page.valid? # Cause before_validation hooks to run
      page
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
        :need_ids => [],
        :publishing_app => 'collections-publisher',
        :rendering_app => 'collections',
        :redirects => [],
        :update_type => "major",
        :details => {},
      })
    end

    it "sets public_updated_at based on the browse page update time" do
      Timecop.travel 3.hours.ago do
        browse_page.save!
      end

      expect(presented_data[:public_updated_at]).to eq(browse_page.updated_at)
    end

    it "includes the necessary routes" do
      expect(presented_data[:routes]).to eq([
        {:path => "/browse/benefits", :type => "exact"},
      ])
    end

    context "linking to related topics" do
      let!(:parent_browse_page) { create(:mainstream_browse_page) }

      before :each do
        browse_page.save!
        parent_browse_page.children << browse_page
        parent_browse_page.save!
      end

      it "sends empty array without any" do
        expect(presented_data[:links]).to eq({
          "related_topics" => [],
        })
      end

      it "includes the content_ids of linked topics sorted by title" do
        bravo = create(:topic, :title => "Bravo")
        alpha = create(:topic, :title => "Alpha")
        browse_page.topics = [bravo, alpha]
        browse_page.save!

        expect(presented_data[:links]).to eq({
          "related_topics" => [alpha.content_id, bravo.content_id],
        })
      end
    end
  end
end
