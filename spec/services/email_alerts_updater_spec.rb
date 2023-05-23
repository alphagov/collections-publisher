require "rails_helper"

RSpec.describe "EmailAlertsUpdater" do
  let(:email_alert_api) { instance_double(GdsApi::EmailAlertApi) }

  before do
    allow(Services).to receive(:email_alert_api).and_return(email_alert_api)
    allow(email_alert_api).to receive(:bulk_migrate)

    @item = create(:topic, :published, parent: create(:topic, slug: "mot"),
                                       slug: "provide-mot-training",
                                       title: "Provide MOT training")
  end

  context "when the successor is a document other than a document collection" do
    it "calls the email alert unsubscriber" do
      successor = OpenStruct.new(base_path: "/guidance/become-an-mot-training-provider")

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
      successor = OpenStruct.new(base_path: "/government/collections/brexit-guidance")

      expect(EmailAlertsUnsubscriber).to receive(:call).never

      EmailAlertsUpdater.call(item: @item, successor:)
    end
  end

  ## Name of field tbc
  # #TODO: return topic taxonomy override from content item - requires changes to topic archiving form
  context "when the successor is a document collection with the taxonomy override field" do
    it "calls the bulk migrator endpoint, not the unsubscriber" do
      successor = OpenStruct.new(base_path: "/government/collections/brexit-guidance", topic_taxonomy_override: "/brexit-guidance")

      expect(EmailAlertsUnsubscriber).to receive(:call).never

      EmailAlertsUpdater.call(item: @item, successor:)

      expect(Services.email_alert_api).to have_received(:bulk_migrate).with(successor_slug: nil, source_slug: nil) # TODO: assert on the correct things
    end
  end
end
