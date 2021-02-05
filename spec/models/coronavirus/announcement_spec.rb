require "rails_helper"

RSpec.describe Coronavirus::Announcement, type: :model do
  let(:announcement) { create :coronavirus_announcement }

  describe "validations" do
    it "should belong to a page" do
      should validate_presence_of(:page)
    end

    it "fails if page does not exist" do
      announcement.page = nil

      expect(announcement).not_to be_valid
    end

    it "is created with valid attributes" do
      expect(announcement).to be_valid
      expect(announcement.save).to eql true
      expect(announcement).to be_persisted
    end

    it "requires title" do
      announcement.title = ""

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:title)
    end

    it "requires a path" do
      announcement.path = ""

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:path)
    end

    it "requires a path to begin with /" do
      announcement.path = "government/coronavirus"

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:path)
    end

    it "requires a published at time" do
      announcement.published_at = ""

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:published_at)
    end

    it "should only have four digits for the year" do
      announcement.published_at = "12345-09-10 23:00:00"

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:published_at)
    end
  end

  describe "position" do
    it "should default to position 1 if it is the first announcement to have been added" do
      page = create(:coronavirus_page)
      expect(page.announcements.count).to eq 0

      announcement = create(:coronavirus_announcement, page: page)
      expect(announcement.position).to eq 1
    end

    it "should increment if there are existing announcements" do
      page = create(:coronavirus_page)
      create(:coronavirus_announcement, page: page)
      expect(page.announcements.count).to eq 1

      announcement = create(:coronavirus_announcement, page: page)
      expect(announcement.position).to eq 2
    end

    it "should update announcement positions when an announcement is deleted" do
      page = create(:coronavirus_page)
      create(:coronavirus_announcement, page: page)
      create(:coronavirus_announcement, page: page)
      expect(page.announcements.count).to eq 2

      original_announcement_one = page.announcements.first
      original_announcement_two = page.announcements.last
      expect(original_announcement_one.position).to eq 1
      expect(original_announcement_two.position).to eq 2

      original_announcement_one.destroy!
      page.reload
      original_announcement_two.reload

      expect(original_announcement_two.position).to eq 1
      expect(page.announcements.first).to eq original_announcement_two
      expect(page.announcements.count).to eq 1
    end
  end
end
