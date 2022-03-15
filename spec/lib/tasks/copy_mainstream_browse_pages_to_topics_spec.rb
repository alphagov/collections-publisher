require "rails_helper"

RSpec.describe "rake publishing_api:copy_mainstream_browse_pages_to_topics", type: :task do
  before do
    # allow(TagBroadcaster).to receive(:broadcast)
    Rake::Task["publishing_api:copy_mainstream_browse_pages_to_topics"].reenable
    # stub_any_publishing_api_put_content
  end

  fit "creates a Topic" do
    mainstream_browse_page = create(:mainstream_browse_page, :published)

    Rake::Task["publishing_api:copy_mainstream_browse_pages_to_topics"].invoke

    expect(Topic.count).to eq(1)
  end
end
