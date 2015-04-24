require "spec_helper"

describe "associating topics to mainstream browse pages" do
  before do
    stub_user.permissions << "GDS Editor"
    stub_all_panopticon_tag_calls
  end

  context "existing mainstream browse pages" do
    let!(:mainstream_browse_page) { create(:mainstream_browse_page) }
    let!(:topic)                  { create(:topic) }
    let!(:topic_two)              { create(:topic) }

    it "should show any topics that are associated" do
      mainstream_browse_page.topics = [topic, topic_two]
      expect(mainstream_browse_page.save).to be_true

      visit mainstream_browse_page_path(mainstream_browse_page)

      expect(page.status_code).to eq(200)
      expect(page).to have_content(topic.title)
      expect(page).to have_content(topic_two.title)
    end

    it "should allow associating topics" do
      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      within "form.resource" do
        select topic.title, :from => "mainstream_browse_page_topics"
        select topic_two.title, :from => "mainstream_browse_page_topics"
        click_on "Save"
      end

      expect(page.status_code).to eq(200)
      expect(page).to have_content(topic.title)
      expect(page).to have_content(topic_two.title)
    end

    it "should allow removing associated topics" do
      mainstream_browse_page.topics = [topic, topic_two]
      expect(mainstream_browse_page.save).to be_true

      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      within "form.resource" do
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
      expect(mainstream_browse_page.save).to be_true

      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      expect(page.status_code).to eq(200)
      expect(page).to have_select("mainstream_browse_page_topics", selected: [topic.title, topic_two.title])
    end
  end
end
