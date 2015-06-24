require 'rails_helper'

RSpec.describe Redirect do
  describe '#tag' do
    it 'deletes itself if the parent tag is deleted' do
      topic = create(:topic)
      redirect = create(:redirect, tag: topic)

      topic.destroy

      expect { redirect.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
