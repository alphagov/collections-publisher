require "rails_helper"
require_relative "../../lib/file_maker"

RSpec.describe FileMaker do
  let(:tag_type) { "tag_type" }
  let(:parent_base_path) { "/tag_type/foo" }
  let(:file_path) { "tag_type/tagged_to_foo.csv" }

  subject { described_class.new(tag_type, parent_base_path) }

  it "#make_directory" do
    subject.make_directory
    expect(File.directory?(tag_type)).to be true
  end

  it "#file_path" do
    expect(subject.file_path).to eq file_path
  end

  after(:each) do
    FileUtils.rm_rf("tag_type")
  end
end
