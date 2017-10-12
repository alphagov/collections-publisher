require 'rails_helper'

RSpec.describe EmailAlertSignupPublisher do
  include ContentStoreHelpers

  describe '#republish_email_alert_signups' do
    it "sends all email alert signup content items to the publishing-api" do
      stub_content_store!
      parent_topic = create(:topic, title: "Parent Topic", slug: "parent-topic")
      create(:topic, title: "Child Topic", slug: "child-topic", parent_id: parent_topic.id)

      EmailAlertSignupPublisher.new.republish_email_alert_signups

      expect(stubbed_content_store).to have_content_item_slug('/topic/parent-topic/child-topic/email-signup')
    end
  end
end
