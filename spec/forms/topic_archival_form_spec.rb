require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.describe TopicArchivalForm do
  include GdsApi::TestHelpers::ContentStore

  describe '#topics' do
    it 'returns published topics that can be successors' do
      create(:topic, :draft)
      create(:topic, :archived)
      published = create(:topic, :published)
      topic_self = create(:topic, :published)

      topics = TopicArchivalForm.new(tag: topic_self).topics

      expect(topics).to eql([published])
    end
  end

  describe '#successor_path' do
    it 'is not valid if the URL returns a 404 status code' do
      content_store_does_not_have_item('/not-here')

      form = TopicArchivalForm.new(successor_path: "/not-here")

      expect(form.valid?).to eql(false)
    end

    it 'is not valid if its not really a URL' do
      form = TopicArchivalForm.new(successor_path: "/i-Am Not A URL")

      expect(form.valid?).to eql(false)
    end

    it 'is not valid if it does not start with a slash' do
      form = TopicArchivalForm.new(successor_path: "am-not-a-url")

      expect(form.valid?).to eql(false)
    end

    it 'is valid if the URL returns 200' do
      content_store_has_item('/existing-item')

      form = TopicArchivalForm.new(successor_path: "/existing-item")

      expect(form.valid?).to eql(true)
    end
  end
end
