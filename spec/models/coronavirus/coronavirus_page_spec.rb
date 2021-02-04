require "rails_helper"

RSpec.describe Coronavirus::CoronavirusPage do
  describe "scopes" do
    let!(:business) { create :coronavirus_page, :business }
    let!(:landing) { create :coronavirus_page, :landing }
    let!(:education) { create :coronavirus_page, :education }
    let!(:workers) { create :coronavirus_page, :workers }

    it "topic_page" do
      expect(Coronavirus::CoronavirusPage.topic_page.first).to eq landing
    end

    it "sub_topics" do
      expect(Coronavirus::CoronavirusPage.subtopic_pages)
        .to eq [business, education, workers]
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

  describe "dependencies" do
    let!(:workers) { create :coronavirus_page, :workers }
    let!(:sub_section) { create :sub_section, coronavirus_page: workers }

    it "deletion destroys all child subsections" do
      expect { workers.destroy }
        .to change { Coronavirus::SubSection.count }.by(-1)
    end
  end
end
