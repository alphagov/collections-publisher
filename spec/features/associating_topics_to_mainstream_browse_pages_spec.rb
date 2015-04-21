require "spec_helper"

describe "associating topics to mainstream browse pages" do
  before do
    stub_user.permissions << "GDS Editor"
    stub_all_panopticon_tag_calls
  end

  context "existing mainstream browse pages" do
    let!(:mainstream_browse_page) { create(:mainstream_browse_page) }
    let!(:topic)                  { create(:topic) }

    before do
      mainstream_browse_page.save
      topic.save
    end

    it "should show any topics that are associated" do
      mainstream_browse_page.topics << topic
      expect(mainstream_browse_page.save).to be_true

      visit mainstream_browse_page_path(mainstream_browse_page)

      expect(page.status_code).to eq(200)
      expect(page).to have_content(topic.title)
    end

    it "should allow associating topics" do
      visit edit_mainstream_browse_page_path(mainstream_browse_page)

      within "form.resource" do
        select topic.title, :from => "mainstream_browse_page_topics"
        click_on "Save"
      end

      mainstream_browse_page.reload
      expect(page.status_code).to eq(200)
      expect(page).to have_content(topic.title)
    end
  end
end
