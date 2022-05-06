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

  it "doesn't run in production" do
    allow(Rails).to receive(:env) { "production".inquiry }

    expect { Rake::Task["browse_topics:copy_mainstream_browse_pages_to_topics"].invoke }.to raise_error(
      "This rake task is not intended to be run in production",
    )

    expect(CopyMainstreamBrowsePagesToTopics).not_to have_received(:call)
  end
end

RSpec.describe "rake browse_topics:copy_mainstream_browse_pages_tree_to_topics", type: :task do
  before do
    allow(CopyMainstreamBrowsePagesToTopics).to receive(:call)
    Rake::Task["browse_topics:copy_mainstream_browse_pages_tree_to_topics"].reenable
  end

  it "doesn't run in production" do
    allow(Rails).to receive(:env) { "production".inquiry }

    expect { Rake::Task["browse_topics:copy_mainstream_browse_pages_tree_to_topics"].invoke }.to raise_error(
      "This rake task is not intended to be run in production",
    )

    expect(CopyMainstreamBrowsePagesToTopics).not_to have_received(:call)
  end

  it "doesn't try to copy over not published mainstream browse pages" do
    create(:mainstream_browse_page)
    draft = create(:mainstream_browse_page, :draft)

    expect { Rake::Task["browse_topics:copy_mainstream_browse_pages_tree_to_topics"].invoke(draft.content_id) }.to raise_error(
      "You can only copy over published Mainstream browse pages",
    )

    expect(CopyMainstreamBrowsePagesToTopics).not_to have_received(:call)
  end

  it "calls the service with all pages in the tree, given a top level topic" do
    create(:mainstream_browse_page)
    create(:mainstream_browse_page, :archived)
    top_level = create(:mainstream_browse_page, :published)
    second_level_child = create(:mainstream_browse_page, :published, parent: top_level)
    second_level_sibling = create(:mainstream_browse_page, :published, parent: top_level)

    Rake::Task["browse_topics:copy_mainstream_browse_pages_tree_to_topics"].invoke(top_level.content_id)

    expect(CopyMainstreamBrowsePagesToTopics).to have_received(:call).exactly(1).time
    expect(CopyMainstreamBrowsePagesToTopics).to have_received(:call).with(
      contain_exactly(top_level, second_level_child, second_level_sibling),
    )
  end

  it "calls the service with all pages in the tree given a second level topic" do
    top_level = create(:mainstream_browse_page, :published)
    second_level_child = create(:mainstream_browse_page, :published, parent: top_level)
    second_level_sibling = create(:mainstream_browse_page, :published, parent: top_level)

    Rake::Task["browse_topics:copy_mainstream_browse_pages_tree_to_topics"].invoke(second_level_child.content_id)

    expect(CopyMainstreamBrowsePagesToTopics).to have_received(:call).with(
      contain_exactly(top_level, second_level_child, second_level_sibling),
    )
  end
end
