require "rails_helper"

RSpec.describe Coronavirus::TimelineEntry do
  it { should validate_presence_of(:heading) }
  it { should validate_length_of(:heading).is_at_most(255) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:national_applicability) }

  describe "position" do
    let(:page) { create(:coronavirus_page) }

    it "should default to position 1 if it is the first timeline entry to have been added" do
      expect(page.timeline_entries.count).to eq 0

      timeline_entry = create(:coronavirus_timeline_entry, page: page)
      expect(timeline_entry.reload.position).to eq 1
    end

    it "if more timeline entries are added, the previous entries will increment position by 1" do
      expect(page.timeline_entries.count).to eq 0

      first_timeline_entry = create(:coronavirus_timeline_entry, page: page, heading: "one")
      expect(first_timeline_entry.reload.position).to eq 1

      second_timeline_entry = create(:coronavirus_timeline_entry, page: page, heading: "two")

      expect(first_timeline_entry.reload.position).to eq 2
      expect(second_timeline_entry.reload.position).to eq 1
    end

    it "should update timeline entry positions when a timeline entry is deleted" do
      original_timeline_entry_one = create(:coronavirus_timeline_entry, page: page)
      original_timeline_entry_two = create(:coronavirus_timeline_entry, page: page)
      expect(page.timeline_entries.count).to eq 2

      expect(original_timeline_entry_one.reload.position).to eq 2
      expect(original_timeline_entry_two.reload.position).to eq 1

      original_timeline_entry_two.destroy!
      page.reload
      original_timeline_entry_one.reload

      expect(original_timeline_entry_one.position).to eq 1
      expect(page.timeline_entries.count).to eq 1
    end
  end

  describe "national_applicability" do
    let(:timeline_entry) { create(:coronavirus_timeline_entry) }

    it "must have valid UK nations" do
      timeline_entry.national_applicability = %w[france]

      expect(timeline_entry).not_to be_valid
      expect(timeline_entry.errors).to have_key(:national_applicability)
    end

    it "allows national_applicability to be set to a UK nation" do
      timeline_entry.national_applicability = %w[wales]

      expect(timeline_entry).to be_valid
    end

    it "allows national_applicability to be set to multiple UK nations" do
      timeline_entry.national_applicability = %w[england wales]

      expect(timeline_entry).to be_valid
    end
  end

  describe "national_applicability_text" do
    let(:timeline_entry) { create(:coronavirus_timeline_entry) }

    it "displays a list of nations" do
      timeline_entry.national_applicability = %w[england wales]

      expect(timeline_entry.national_applicability_text).to eq("England, Wales")
    end

    it "displays UK Wide when tagged to all nations" do
      timeline_entry.national_applicability = %w[england wales northern_ireland scotland]

      expect(timeline_entry.national_applicability_text).to eq("UK Wide")
    end
  end
end
