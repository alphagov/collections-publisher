require 'rails_helper'

RSpec.describe RedirectPublisher do
  include ContentStoreHelpers

  describe '#republish_redirects' do
    it "sends all redirects to the publishing-api" do
      stub_content_store!
      create(:redirect_item, from_base_path: '/foo')

      RedirectPublisher.new.republish_redirects

      expect(stubbed_content_store).to have_content_item_slug('/foo')
    end
  end
end
