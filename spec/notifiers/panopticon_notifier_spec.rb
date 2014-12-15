require "spec_helper"

RSpec.describe PanopticonNotifier do
  let(:panopticon) {
    double(:panopticon, create_tag: nil, put_tag: nil, publish_tag: nil)
  }

  before do
    CollectionsPublisher.services(:panopticon, panopticon)
  end

  let(:tag_hash) { double(:tag_hash) }
  let(:presenter) { double(:tag_presenter, render_for_panopticon: tag_hash) }

  describe '#create_tag' do
    it 'sends a request to Panopticon to create the tag' do
      PanopticonNotifier.create_tag(presenter)

      expect(panopticon).to have_received(:create_tag).with(tag_hash)
    end
  end

  describe '#update_tag' do
    let(:tag_type) { double(:tag_type) }
    let(:tag_id) { double(:tag_id) }

    before do
      allow(tag_hash).to receive(:[]).with(:tag_type).and_return(tag_type)
      allow(tag_hash).to receive(:[]).with(:tag_id).and_return(tag_id)
    end

    it 'sends a request to Panopticon to update the tag' do
      PanopticonNotifier.update_tag(presenter)

      expect(panopticon).to have_received(:put_tag).with(tag_type, tag_id, tag_hash)
    end
  end

  describe '#publish_tag' do
    let(:tag_type) { double(:tag_type) }
    let(:tag_id) { double(:tag_id) }

    before do
      allow(tag_hash).to receive(:[]).with(:tag_type).and_return(tag_type)
      allow(tag_hash).to receive(:[]).with(:tag_id).and_return(tag_id)
    end

    it 'sends a request to Panopticon to publish the tag' do
      PanopticonNotifier.publish_tag(presenter)

      expect(panopticon).to have_received(:publish_tag).with(tag_type, tag_id)
    end
  end
end
