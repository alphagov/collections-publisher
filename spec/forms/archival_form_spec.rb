require 'rails_helper'

RSpec.describe ArchivalForm do
  describe '#topics' do
    it 'returns published topics that can be successors' do
      draft = create(:topic, :draft)
      archived = create(:topic, :archived)
      published = create(:topic, :published)
      topic_self = create(:topic, :published)

      topics = ArchivalForm.new(tag: topic_self).topics

      expect(topics).to eql([published])
    end
  end
end
