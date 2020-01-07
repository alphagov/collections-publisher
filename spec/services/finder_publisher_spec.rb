require "rails_helper"

RSpec.describe FinderPublisher do
  before do
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:publish)
    allow(Services.publishing_api).to receive(:unpublish)
  end

  it "publishes valid finders" do
    Dir[Rails.root.join("lib", "finders", "*.json")].each do |file_path|
      finder_item = JSON.parse(File.read(file_path))

      subject = described_class.new(finder_item)

      expect(subject.content_item).to be_valid_against_schema("finder")
    end
  end

  it "publishes the finder" do
    example_finder = JSON.parse(File.read("lib/finders/organisation_content.json"))
    content_id = example_finder["content_id"]

    described_class.call(example_finder)

    expect(Services.publishing_api).to have_received(:put_content).with(content_id, example_finder)
    expect(Services.publishing_api).to have_received(:publish).with(content_id)
  end

  describe "#unpublish" do
    it "unpublishes the finder" do
      file_path = Rails.root.join("lib", "finders", "organisation_content.json")
      content_item = JSON.parse(File.read(file_path))
      content_id = content_item["content_id"]
      options = { type: "gone" }

      described_class.new(content_item).unpublish(options)

      expect(Services.publishing_api).to have_received(:unpublish).with(content_id, options)
    end
  end
end
