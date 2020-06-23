require "rails_helper"

RSpec.describe CoronavirusPage do
  describe "scopes" do
    let!(:business) { create :coronavirus_page, :business }
    let!(:landing) { create :coronavirus_page, :landing }
    let!(:education) { create :coronavirus_page, :education }
    let!(:employees) { create :coronavirus_page, :employees }

    it "topic_page" do
      expect(CoronavirusPage.topic_page.first).to eq landing
    end

    it "sub_topics" do
      expect(CoronavirusPage.subtopic_pages).to eq [business, education, employees]
    end
  end
end
