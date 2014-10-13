require "spec_helper"

RSpec.describe PanopticonNotifier do
  let(:panopticon) { double(:panopticon, create_tag: nil) }

  before do
    CollectionsPublisher.services(:panopticon, panopticon)
  end

  describe '#create(tag)' do
    let(:tag_hash) { double(:tag_hash) }
    let(:presenter) { double(:tag_presenter, render_for_panopticon: tag_hash) }

    it 'sends a request to Panopticon to create the tag' do
      PanopticonNotifier.create_tag(presenter)

      expect(panopticon).to have_received(:create_tag).with(tag_hash)
    end
  end
end
