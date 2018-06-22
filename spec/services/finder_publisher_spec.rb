require 'rails_helper'

RSpec.describe FinderPublisher do
  before do
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:publish)
  end

  it "publishes valid finders" do
    Dir[Rails.root + "lib/finders/*.json"].each do |file_path|
      finder_item = JSON.parse(File.read(file_path))

      subject = described_class.new(finder_item)

      expect(subject.content_item).to be_valid_against_schema('finder')
    end
  end

  it "publishes the finder" do
    example_finder = JSON.parse(File.read("lib/finders/organisation_content.json"))
    content_id = example_finder["content_id"]

    described_class.call(example_finder)

    expect(Services.publishing_api).to have_received(:put_content).with(content_id, example_finder)
    expect(Services.publishing_api).to have_received(:publish).with(content_id)
  end
end
