require "rails_helper"

RSpec.describe Coronavirus::Page do
  describe "scopes" do
    let!(:business) { create :coronavirus_page, :business }
    let!(:landing) { create :coronavirus_page, :landing }
    let!(:education) { create :coronavirus_page, :education }
    let!(:workers) { create :coronavirus_page, :workers }

    it "topic_page" do
      expect(described_class.topic_page.first).to eq landing
    end

    it "sub_topics" do
      expect(described_class.subtopic_pages)
        .to eq [business, education, workers]
    end
  end

  describe "validations" do
    let(:page) { create :coronavirus_page }

    describe "state validations" do
      it "has a default state when created" do
        expect(page.state).to eq "draft"
      end

      it "state cannot be nil" do
        page.state = ""
        expect(page).not_to be_valid
      end

      it "state must be draft or published" do
        page.state = "lovely"
        expect(page).not_to be_valid
      end
    end

    describe "header section validations" do
      it { should validate_length_of(:header_title).is_at_most(255) }

      describe "header_link_url validation" do
        it { should allow_values("/path", "https://example.com").for(:header_link_url) }
        it { should_not allow_values("not a url").for(:header_link_url) }

        it "doesn't apply the URL format validation when the field is blank" do
          page.header_link_url = ""
          expect(page).to be_valid
        end
      end
    end
  end

  describe "dependencies" do
    let!(:workers) { create :coronavirus_page, :workers }
    let!(:sub_section) { create :coronavirus_sub_section, page: workers }

    it "deletion destroys all child subsections" do
      expect { workers.destroy }
        .to change { Coronavirus::SubSection.count }.by(-1)
    end
  end
end
