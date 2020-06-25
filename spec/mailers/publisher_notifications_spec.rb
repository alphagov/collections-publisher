require "rails_helper"

RSpec.describe PublisherNotifications do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  describe "#publish_without_2i" do
    it "generates an email" do
      step_by_step_page = create(:step_by_step_page)
      user = create(:user, name: "Peter")
      mail_subject = "[PUBLISHER] Step by step published without 2i review for '#{step_by_step_page.title}'"

      mail = described_class.publish_without_2i(step_by_step_page, user)

      expect(mail.to).to eq([PublisherNotifications::PUBLISH_WITHOUT_2I_EMAIL])
      expect(mail.subject).to eq(mail_subject)
      expect(mail.body.to_s).to include("Peter")
      expect(mail.body.to_s).to include(step_by_step_page.title)
      expect(mail.body.to_s).to include("https://www.test.gov.uk/#{step_by_step_page.slug}")
    end
  end
end
