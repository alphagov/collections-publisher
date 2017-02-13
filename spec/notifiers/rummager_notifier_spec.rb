require 'rails_helper'

RSpec.describe RummagerNotifier do
  before do
    allow(rummager).to receive(:add_document)
  end

  describe '#notify' do
    it 'does not send draft topics to rummager' do
      topic = create(:topic, :draft)

      RummagerNotifier.new(topic).notify

      expect(rummager).not_to have_received(:add_document)
    end

    it 'sends published topics to rummager' do
      topic = create(:topic, :published)

      RummagerNotifier.new(topic).notify

      expect(rummager).to have_received(:add_document)
    end

    it 'sends published topics to rummager' do
      topic = create(:topic, :published,
        content_id: '28ac662c-09cf-4baa-9e7c-98339a2a3bcd',
        title: 'A Topic',
        slug: 'a-test-topic',
        description: 'A description.'
      )

      RummagerNotifier.new(topic).notify

      expect(rummager).to have_received(:add_document)
        .with("edition", "/topic/a-test-topic", content_id: '28ac662c-09cf-4baa-9e7c-98339a2a3bcd',
          content_store_document_type: "topic",
          description: 'A description.',
          format: 'specialist_sector',
          link: '/topic/a-test-topic',
          publishing_app: 'collections-publisher',
          rendering_app: 'collections',
          slug: 'a-test-topic',
          title: 'A Topic',
        )
    end

    it 'sends published browse pages to rummager' do
      browse_page = create(:mainstream_browse_page, :published,
        content_id: '28ac662c-09cf-4baa-9e7c-98339a2a3bcd',
        title: 'A Browse Page',
        slug: 'a-browse-page',
        description: 'A description.'
      )

      RummagerNotifier.new(browse_page).notify

      expect(rummager).to have_received(:add_document)
        .with("edition", "/browse/a-browse-page", content_id: '28ac662c-09cf-4baa-9e7c-98339a2a3bcd',
          content_store_document_type: "mainstream_browse_page",
          description: 'A description.',
          format: 'mainstream_browse_page',
          link: '/browse/a-browse-page',
          publishing_app: 'collections-publisher',
          rendering_app: 'collections',
          slug: 'a-browse-page',
          title: 'A Browse Page',
        )
    end

    it 'sends the full slug for a subtopic' do
      parent = create(:topic, :published, :slug => 'a-parent')
      topic = create(:topic, :published,
        parent: parent,
        title: 'A Topic',
        slug: 'a-test-topic',
        description: 'A description.')

      RummagerNotifier.new(topic).notify

      expect(rummager).to have_received(:add_document)
        .with("edition", "/topic/a-parent/a-test-topic", hash_including(slug: 'a-parent/a-test-topic'))
    end
  end

  def rummager
    Services.rummager
  end
end
