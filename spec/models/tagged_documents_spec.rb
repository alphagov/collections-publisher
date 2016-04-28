require 'rails_helper'

RSpec.describe TaggedDocuments do
  describe '#documents' do
    it 'returns empty array for topics that have no documents tagged to them' do
      topic = create(:topic, slug: 'a-child', parent: create(:topic, slug: 'a-parent'))
      stub_request(:get, RummagerHelper::SEARCH_ENDPOINT)
        .with(query: { count: 1_000, fields: %w[link title], filter_specialist_sectors: %w[a-parent/a-child], start: 0 })
        .to_return(body: JSON.dump(results: []))

      documents = TaggedDocuments.new(topic).documents

      expect(documents).to eql([])
    end

    it 'returns the documents tagged to a topic' do
      topic = create(:topic, slug: 'a-child', parent: create(:topic, slug: 'a-parent'))
      stub_request(:get, RummagerHelper::SEARCH_ENDPOINT)
        .with(query: { count: 1_000, fields: %w[link title], filter_specialist_sectors: %w[a-parent/a-child], start: 0 })
        .to_return(body: JSON.dump(results: [ { link: "/some-link", title: "The Title" }, { link: "/some-other-link", title: "Another Title" }]))

      documents = TaggedDocuments.new(topic).documents

      expect(documents.size).to eql(2)
    end

    it 'returns the documents tagged to a mainstream-browse-page' do
      topic = create(:mainstream_browse_page, slug: 'a-child', parent: create(:mainstream_browse_page, slug: 'a-parent'))
      stub_request(:get, RummagerHelper::SEARCH_ENDPOINT)
        .with(query: { count: 1_000, fields: %w[link title], filter_mainstream_browse_pages: %w[a-parent/a-child], start: 0 })
        .to_return(body: JSON.dump(results: [ { link: "/some-link", title: "The Title" }, { link: "/some-other-link", title: "Another Title" }]))

      documents = TaggedDocuments.new(topic).documents

      expect(documents.size).to eql(2)
    end

    it 'returns turns the results into document classes' do
      topic = create(:topic, slug: 'a-child', parent: create(:topic, slug: 'a-parent'))
      stub_request(:get, RummagerHelper::SEARCH_ENDPOINT)
        .with(query: { count: 1_000, fields: %w[link title], filter_specialist_sectors: %w[a-parent/a-child], start: 0 })
        .to_return(body: JSON.dump(results: [ { link: "/some-link", title: "The Title" }]))

      document = TaggedDocuments.new(topic).documents.first

      expect(document.title).to eql('The Title')
      expect(document.base_path).to eql('/some-link')
    end
  end
end
