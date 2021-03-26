require "rails_helper"

RSpec.describe AbsolutePathOrHttpsUrlValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      attr_accessor :url

      validates :url, absolute_path_or_https_url: true
    end
  end

  before { stub_const("ExampleModel", record_class) }

  let(:generic_error) do
    "needs to be a https:// URL or a path prefixed with /"
  end

  it "is valid for a https URL" do
    record = ExampleModel.new(url: "https://www.example.com")
    expect(record).to be_valid
  end

  it "is valid for an absolute path" do
    record = ExampleModel.new(url: "/test?path=this")
    expect(record).to be_valid
  end

  it "is invalid when a URL has errors" do
    record = ExampleModel.new(url: "bad url")
    expect(record).not_to be_valid
    expect(record.errors[:url]).to include("is not a valid URL")
  end

  it "sets an error for a non https URL" do
    record = ExampleModel.new(url: "http://not-secure.com")
    expect(record).not_to be_valid
    expect(record.errors[:url]).to include(generic_error)
  end

  it "sets an error for a path that isn't absolute" do
    record = ExampleModel.new(url: "relative-path")
    expect(record).not_to be_valid
    expect(record.errors[:url]).to include(generic_error)
  end

  it "sets an error for a relative URL with a host" do
    record = ExampleModel.new(url: "//test.com/relative-path")
    expect(record).not_to be_valid
    expect(record.errors[:url]).to include(generic_error)
  end
end
