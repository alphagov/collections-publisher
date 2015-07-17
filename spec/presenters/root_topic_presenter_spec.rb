require 'rails_helper'

RSpec.describe RootTopicPresenter do
  describe "#render_for_publishing_api" do
    it "raises if top-level browse pages are not present" do
      expect {
        RootTopicPresenter.new.render_for_publishing_api
      }.to raise_error(RuntimeError)
    end

    it "is valid against the schema" do
      create(:topic, title: "Top-Level Topic 1")
      create(:topic, title: "Top-Level Topic 2")

      rendered = RootTopicPresenter.new.render_for_publishing_api

      expect(rendered).to be_valid_against_schema('topic')
    end

    it "includes draft and published top-level browse pages" do
      page_1 = create(:topic, :published, title: "Top-Level Page 1")
      page_2 = create(:topic, :draft, title: "Top-Level Page 2")

      rendered = RootTopicPresenter.new.render_for_publishing_api

      expect(rendered[:links]["children"]).to eq([
        page_1.content_id,
        page_2.content_id,
      ])
    end

    it ":public_updated_at equals the time of last browse page update" do
      page_1 = create(:topic, title: "Top-Level Topic 1")
      page_2 = create(:topic, title: "Top-Level Topic 2")

      Timecop.travel 3.hours.ago do
        page_1.touch
      end
      page_2.touch

      rendered = RootTopicPresenter.new.render_for_publishing_api

      expect(rendered[:public_updated_at]).to eq(page_2.updated_at.iso8601)
    end
  end
end
