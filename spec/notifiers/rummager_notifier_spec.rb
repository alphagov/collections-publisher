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
        title: 'A Topic',
        slug: 'a-test-topic',
        description: 'A description.')

      RummagerNotifier.new(topic).notify

      expect(rummager).to have_received(:add_document)
        .with("edition", "/topic/a-test-topic", {
          format: 'specialist_sector',
          title: 'A Topic',
          description: 'A description.',
          link: '/topic/a-test-topic',
          slug: 'a-test-topic',
        })
    end

    it 'sends published browse pages to rummager' do
      browse_page = create(:mainstream_browse_page, :published,
        title: 'A Browse Page',
        slug: 'a-browse-page',
        description: 'A description.')

      RummagerNotifier.new(browse_page).notify

      expect(rummager).to have_received(:add_document)
        .with("edition", "/browse/a-browse-page", {
          format: 'mainstream_browse_page',
          title: 'A Browse Page',
          description: 'A description.',
          link: '/browse/a-browse-page',
          slug: 'a-browse-page',
        })
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
        .with("edition", "/topic/a-parent/a-test-topic", hash_including({
          slug: 'a-parent/a-test-topic',
        }))
    end
  end

  def rummager
    CollectionsPublisher.services(:rummager)
  end
end
