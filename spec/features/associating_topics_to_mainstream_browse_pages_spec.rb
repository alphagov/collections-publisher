require "rails_helper"

RSpec.describe "associating topics to mainstream browse pages" do
  include PublishingApiHelpers

  before do
    stub_user.permissions << "GDS Editor"
    stub_all_panopticon_tag_calls
    stub_rummager_linked_content_call
  end

  context "parent mainstream browse pages" do
    let!(:mainstream_browse_page) { create(:mainstream_browse_page) }

    it "should not allow adding any topics" do
      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      within "form" do
        expect(page).to_not have_selector("#mainstream_browse_page_topics")
      end
    end
  end

  context "existing mainstream browse pages" do
    let!(:mainstream_browse_page_parent) { create(:mainstream_browse_page) }
    let!(:mainstream_browse_page)        { create(:mainstream_browse_page, parent: mainstream_browse_page_parent) }
    let!(:topic)                         { create(:topic, title: "Bravo") }
    let!(:topic_two)                     { create(:topic, title: "Alpha") }

    it "should show any topics that are associated" do
      mainstream_browse_page.topics = [topic, topic_two]
      expect(mainstream_browse_page.save).to eql true

      visit mainstream_browse_page_path(mainstream_browse_page)

      expect(page.status_code).to eq(200)
      expect(page).to have_content(topic.title)
      expect(page).to have_content(topic_two.title)
    end

    it "should sort topic dropdown and include parent topic title" do
      create(:topic, parent: topic, title: "Bravo")
      create(:topic, parent: topic, title: "Alpha")
      create(:topic, parent: topic, title: "Charlie")
      create(:topic, parent: topic_two, title: "Bravo")
      create(:topic, parent: topic_two, title: "Alpha")

      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      topic_titles = page.all(:css, "#mainstream_browse_page_topics option").map(&:text)
      expect(topic_titles).to eq([
        "Alpha",
        "Alpha / Alpha",
        "Alpha / Bravo",
        "Bravo",
        "Bravo / Alpha",
        "Bravo / Bravo",
        "Bravo / Charlie",
      ])
    end

    it "should allow associating topics" do
      stub_put_content_links_and_publish_to_publishing_api
      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      within "form" do
        select topic.title, :from => "mainstream_browse_page_topics"
        select topic_two.title, :from => "mainstream_browse_page_topics"
        click_on "Save"
      end

      expect(page.status_code).to eq(200)
      expect(page).to have_content(topic.title)
      expect(page).to have_content(topic_two.title)
    end

    it "should allow removing associated topics" do
      stub_put_content_links_and_publish_to_publishing_api
      mainstream_browse_page.topics = [topic, topic_two]
      expect(mainstream_browse_page.save).to eql true

      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      within "form" do
        unselect topic.title, :from => "mainstream_browse_page_topics"
        unselect topic_two.title, :from => "mainstream_browse_page_topics"
        click_on "Save"
      end

      visit mainstream_browse_page_path(mainstream_browse_page)

      expect(page.status_code).to eq(200)
      expect(page).to_not have_content(topic.title)
      expect(page).to_not have_content(topic_two.title)
    end

    it "should show the already assigned topics when editing" do
      mainstream_browse_page.topics = [topic, topic_two]
      expect(mainstream_browse_page.save).to eql true

      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      expect(page.status_code).to eq(200)
      expect(page).to have_select("mainstream_browse_page_topics", selected: [topic.title, topic_two.title])
    end
  end
end
