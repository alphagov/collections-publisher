require "rails_helper"

RSpec.describe "EmailAlertsUpdater" do
  before do
    @item = create(:topic, :published, parent: create(:topic, slug: "mot"),
                                       slug: "provide-mot-training",
                                       title: "Provide MOT training")
  end

  context "when the successor is a document other than a document collection" do
    it "calls the email alert unsubscriber" do
      successor = OpenStruct.new(base_path: "/guidance/become-an-mot-training-provider", subroutes: [])

      expected_email_body = <<~BODY
        This topic has been archived. You will not get any more emails about it.

        You can find more information about this topic at [#{Plek.website_root}/guidance/become-an-mot-training-provider](#{Plek.website_root}/guidance/become-an-mot-training-provider).
      BODY

      expect(EmailAlertsUnsubscriber).to receive(:call).with(item: @item, body: expected_email_body)

      EmailAlertsUpdater.call(item: @item, successor:)
    end
  end

  context "when the successor is a document collection" do
    it "does not call the email alert unsubscriber" do
      successor = OpenStruct.new(base_path: "/government/collections/brexit-guidance", subroutes: [])

      expect(EmailAlertsUnsubscriber).to receive(:call).never

      EmailAlertsUpdater.call(item: @item, successor:)
    end
  end
end
