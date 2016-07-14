require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe TaxonForm do
  include GdsApi::TestHelpers::PublishingApiV2

  describe '.build' do
    let(:content_id) { SecureRandom.uuid }
    let(:subject) { described_class.build(content_id: content_id) }
    let(:content) do
      {
        content_id: content_id,
        title: 'A title',
        base_path: 'A base path'
      }
    end

    before do
      publishing_api_has_item(content)
      publishing_api_has_links(
        content_id: content_id,
        links: {
          topics: [],
          parent: []
      })
    end

    it 'assigns the parents to the form' do
      expect(subject.taxon_parents).to be_empty
    end

    it 'assigns the content id correctly' do
      expect(subject.content_id).to eq(content_id)
    end

    it 'assigns the title correctly' do
      expect(subject.title).to eq(content[:title])
    end

    it 'assigns the base_path correctly' do
      expect(subject.base_path).to eq(content[:base_path])
    end

    context 'with existing links' do
      let(:parents) { ["CONTENT-ID-RTI", "CONTENT-ID-VAT"] }
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: [],
            parent: parents
        })
      end

      it 'assigns the parents to the form' do
        expect(subject.taxon_parents).to eq(parents)
      end
    end
  end
end
