# == Schema Information
#
# Table name: lists
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  sector_id :string(255)
#  index     :integer          default(0), not null
#  dirty     :boolean          default(TRUE), not null
#  topic_id  :integer
#
# Indexes
#
#  index_lists_on_sector_id  (sector_id)
#  index_lists_on_topic_id   (topic_id)
#

require "spec_helper"

RSpec.describe List do
  let(:list) { FactoryGirl.create(:list, dirty: true) }

  describe "#mark_as_published" do
    it "sets #dirty? to false without saving" do
      list.mark_as_published

      expect(list).not_to be_dirty

      list.reload
      expect(list).to be_dirty
    end
  end

  describe "#mark_as_published!" do
    it "sets #dirty? to false and saves" do
      list.mark_as_published!

      expect(list).not_to be_dirty

      list.reload
      expect(list).not_to be_dirty
    end
  end
end
