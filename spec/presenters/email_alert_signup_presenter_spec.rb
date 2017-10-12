require 'rails_helper'

RSpec.describe EmailAlertSignupPresenter do
  describe "#content_payload" do
    it "is valid against the schema" do
      parent_topic = create(:topic, title: "Parent Topic", slug: "parent-topic")
      child_topic = create(:topic, title: "Child Topic", slug: "child-topic", parent_id: parent_topic.id)

      rendered = EmailAlertSignupPresenter.new(child_topic).content_payload

      expect(rendered).to be_valid_against_schema('email_alert_signup')
    end
  end
end
