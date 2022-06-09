require "rails_helper"
require_relative "../../lib/report_writer"

RSpec.describe ReportWriter do
  let(:tag_type) { "topics" }
  let(:parent_base_path) { "/topic/animal-welfare" }
  let(:parent_topic) { "animal-welfare" }
  let(:all_topics_fixture_file_path) { "spec/fixtures/topics.csv" }
  let(:all_topics_csv_fixture) { CSV.read(Rails.root.join(all_topics_fixture_file_path), headers: true) }
  let(:tagged_docs_fixture_file_path) { "spec/fixtures/tagged_docs.csv" }
  let(:tagged_docs_csv_fixture) { CSV.read(Rails.root.join(tagged_docs_fixture_file_path), headers: true) }
  let(:tagged_docs_with_duplicates_fixture_file_path) { "spec/fixtures/tagged_docs_with_duplicates.csv" }
  let(:tagged_docs_with_duplicates_csv_fixture) { CSV.read(Rails.root.join(tagged_docs_with_duplicates_fixture_file_path), headers: true) }

  let(:outcome_tagged_file_path) { "stub/tagged_to_#{parent_topic}.csv" }

  let(:topic_data) { instance_double(TopicData) }
  let(:file_maker) { instance_double(FileMaker) }

  before do
    allow(topic_data).to receive(:all_topics_csv) { all_topics_csv_fixture }
    allow(file_maker).to receive(:make_directory) { FileUtils.mkdir_p("stub") }
    allow(file_maker).to receive(:file_path) { outcome_tagged_file_path }
  end

  subject { described_class.new(tag_type, parent_base_path, file_maker) }

  after(:each) do
    FileUtils.rm_rf("stub")
  end

  it "#tagged_pages" do
    items = [
      {
        title: "Pets info 1",
        base_path: "/pets-info-1",
        content_id: "123",
      },
    ]

    publishing_api_has_linked_items("3e275a11", items: items)

    subject.tagged_pages

    actual = CSV.read(Rails.root.join(outcome_tagged_file_path), headers: true)
    expect(actual[0]).to eq tagged_docs_csv_fixture[0]
  end

  it "#add_duplicate_tagging_info" do
    items = [
      {
        title: "Pets info 1",
        base_path: "/pets-info-1",
        content_id: "123",
      },
    ]

    publishing_api_has_linked_items("3e275a11", items: items)

    stub_publishing_api_has_links(
      {
        "content_id" => "123",
        "links" => {
          "mainstream_browse_pages" => %w[789],
        },
      },
    )

    subject.tagged_pages

    subject.add_duplicate_tagging_info(outcome_tagged_file_path)
    actual = CSV.read(Rails.root.join(outcome_tagged_file_path), headers: true)
    expect(actual[0]).to eq tagged_docs_with_duplicates_csv_fixture[0]
  end
end
