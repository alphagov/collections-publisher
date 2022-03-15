require "rails_helper"

RSpec.describe "rake publishing_api:copy_mainstream_browse_pages_to_topics", type: :task do
  before do
    allow(CopyMainstreamBrowsePageToTopic).to receive(:call)
    Rake::Task["publishing_api:copy_mainstream_browse_pages_to_topics"].reenable
  end

  it "calls the service for all mainstream browse pages" do
    mainstream_browse_page1 = create(:mainstream_browse_page, :published)
    mainstream_browse_page2 = create(:mainstream_browse_page, :published)

    Rake::Task["publishing_api:copy_mainstream_browse_pages_to_topics"].invoke

    expect(CopyMainstreamBrowsePageToTopic).to have_received(:call).exactly(2).times
    expect(CopyMainstreamBrowsePageToTopic).to have_received(:call).with(mainstream_browse_page1)
    expect(CopyMainstreamBrowsePageToTopic).to have_received(:call).with(mainstream_browse_page2)
  end
end
