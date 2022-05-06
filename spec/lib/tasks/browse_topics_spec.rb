require "rails_helper"

RSpec.describe "rake browse_topics:copy_mainstream_browse_pages_to_topics", type: :task do
  before do
    allow(CopyMainstreamBrowsePagesToTopics).to receive(:call)
    Rake::Task["browse_topics:copy_mainstream_browse_pages_to_topics"].reenable
  end

  it "calls the service for published mainstream browse pages" do
    create(:mainstream_browse_page)
    create(:mainstream_browse_page, :archived)
    mainstream_browse_page1 = create(:mainstream_browse_page, :published)
    mainstream_browse_page2 = create(:mainstream_browse_page, :published)

    Rake::Task["browse_topics:copy_mainstream_browse_pages_to_topics"].invoke

    expect(CopyMainstreamBrowsePagesToTopics).to have_received(:call).exactly(1).time
    expect(CopyMainstreamBrowsePagesToTopics).to have_received(:call).with(
      [mainstream_browse_page1, mainstream_browse_page2],
    )
  end
end
