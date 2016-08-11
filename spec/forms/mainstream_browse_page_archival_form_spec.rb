require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.describe MainstreamBrowsePageArchivalForm do
  include GdsApi::TestHelpers::ContentStore

  describe '#browse_pages' do
    it 'returns published mainstream browse pages that can be successors' do
      create(:mainstream_browse_page, :draft)
      create(:mainstream_browse_page, :archived)
      published = create(:mainstream_browse_page, :published)
      mainstream_browse_page_self = create(:mainstream_browse_page, :published)

      mainstream_browse_pages = MainstreamBrowsePageArchivalForm.new(tag: mainstream_browse_page_self).browse_pages

      expect(mainstream_browse_pages).to eql([published])
    end
  end

  describe '#successor_path' do
    it 'is not valid if the URL returns a 404 status code' do
      content_store_does_not_have_item('/not-here')

      form = MainstreamBrowsePageArchivalForm.new(successor_path: "/not-here")

      expect(form.valid?).to eql(false)
    end

    it 'is not valid if its not really a URL' do
      form = MainstreamBrowsePageArchivalForm.new(successor_path: "/i-Am Not A URL")

      expect(form.valid?).to eql(false)
    end

    it 'is not valid if it does not start with a slash' do
      form = MainstreamBrowsePageArchivalForm.new(successor_path: "am-not-a-url")

      expect(form.valid?).to eql(false)
    end

    it 'is valid if the URL returns 200' do
      content_store_has_item('/existing-item')

      form = MainstreamBrowsePageArchivalForm.new(successor_path: "/existing-item")

      expect(form.valid?).to eql(true)
    end
  end
end
