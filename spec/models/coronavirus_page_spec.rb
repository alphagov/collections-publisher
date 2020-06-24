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

  describe "validations" do
    let(:coronavirus_page) { create :coronavirus_page }

    it "has a default state when created" do
      expect(coronavirus_page.state).to eq "draft"
    end

    it "state cannot be nil" do
      coronavirus_page.state = ""
      expect(coronavirus_page).not_to be_valid
    end

    it "state must be draft or published" do
      coronavirus_page.state = "lovely"
      expect(coronavirus_page).not_to be_valid
    end
  end
end
