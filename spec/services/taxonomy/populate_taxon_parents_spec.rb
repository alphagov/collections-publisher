require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe Taxonomy::PopulateTaxonParents do
  include GdsApi::TestHelpers::PublishingApiV2

  describe '.run' do
    let(:content_id) { SecureRandom.uuid }
    let(:linkables) do
      [
        {"title" => "foo", "base_path" => "/foo", "content_id" => content_id},
      ]
    end

    before do
      publishing_api_has_linkables(linkables, document_type: 'taxon')
    end

    it 'copies the links parent to taxon parents' do
      publishing_api_has_links(
        "content_id" => content_id,
        "links" => {
          parent: ['CONTENT-ID-RTI'],
        },
      )

      stub_publishing_api_patch_links(
        content_id,
        links: {
          taxon_parents: ['CONTENT-ID-RTI']
        }
      )

      expect(described_class.run(content_id: content_id)).to eq(['CONTENT-ID-RTI'])
    end

    shared_examples_for 'does not add taxon parents' do
      it { expect(Services.publishing_api).to_not receive(:patch_links) }
      it { expect(described_class.run(content_id: content_id)).to be_nil }
    end

    context 'without links' do
      before do
        publishing_api_has_links("content_id" => content_id)
      end

      it_behaves_like 'does not add taxon parents'
    end
    
    context 'with existing links and taxon parents' do
      before do
        publishing_api_has_links(
          "content_id" => content_id,
          "links" => {
            parent: ['CONTENT-ID-RTI'],
            taxon_parents: ['CONTENT-ID-RTI']
          },
        )
      end

      it_behaves_like 'does not add taxon parents'
    end

    context 'with links with an empty parent' do
      before do
        publishing_api_has_links(
          "content_id" => content_id,
          "links" => {
            parent: []
          },
        )
      end

      it_behaves_like 'does not add taxon parents'
    end

    context 'without parent links' do
      before do
        publishing_api_has_links(
          "content_id" => content_id,
          "links" => {},
        )
      end

      it_behaves_like 'does not add taxon parents'
    end
  end
end
