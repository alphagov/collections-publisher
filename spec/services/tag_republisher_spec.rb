require "rails_helper"

RSpec.describe TagRepublisher do
  include ContentStoreHelpers

  describe '#republish_tags' do
    before { stub_content_store! }

    it 'republishes given tags' do
      create(:mainstream_browse_page, :published, slug: 'a-browse-page')

      TagRepublisher.new.republish_tags(Tag.all)

      expect(stubbed_content_store).to have_content_item_slug('/browse/a-browse-page')
    end

    it 'republishes the browse index page' do
      create(:mainstream_browse_page, :published, slug: 'a-browse-page')

      TagRepublisher.new.republish_tags(Tag.all)

      expect(stubbed_content_store).to have_content_item_slug('/browse')
    end
  end
end
