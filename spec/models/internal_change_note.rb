require "rails_helper"

RSpec.describe InternalChangeNote do
  let!(:internal_change_note) { build(:internal_change_note) }

  it "requires a headline" do
    internal_change_note.headline = nil

    expect(internal_change_note).not_to be_valid
    expect(internal_change_note.errors).to have_key(:headline)
  end
end
