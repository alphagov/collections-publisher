require "rails_helper"

RSpec.describe TimelineEntry do
  it { should validate_presence_of(:heading) }
  it { should validate_length_of(:heading).is_at_most(255) }
  it { should validate_presence_of(:content) }

  describe "position" do
    let(:coronavirus_page) { create(:coronavirus_page) }

    it "should default to position 1 if it is the first timeline entry to have been added" do
      expect(coronavirus_page.timeline_entries.count).to eq 0

      timeline_entry = create(:timeline_entry, coronavirus_page: coronavirus_page)
      expect(timeline_entry.reload.position).to eq 1
    end

    it "if more timeline entries are added, the previous entries will increment position by 1" do
      expect(coronavirus_page.timeline_entries.count).to eq 0

      first_timeline_entry = create(:timeline_entry, coronavirus_page: coronavirus_page, heading: "one")
      expect(first_timeline_entry.reload.position).to eq 1

      second_timeline_entry = create(:timeline_entry, coronavirus_page: coronavirus_page, heading: "two")

      expect(first_timeline_entry.reload.position).to eq 2
      expect(second_timeline_entry.reload.position).to eq 1
    end
  end
end
