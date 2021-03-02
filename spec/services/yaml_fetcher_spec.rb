require "rails_helper"

RSpec.describe YamlFetcher do
  let(:random_epoch) { rand(10**10) }
  let(:url) { Faker::Internet.url(host: "example.com") + "?cache-bust=#{random_epoch}" }
  let(:yaml) { File.read(Rails.root.join("spec/fixtures/simple.yml")) }
  let(:body) { "something" }
  let(:stub_response) { { body: body } }

  subject { described_class.new(url) }

  before do
    Timecop.freeze(Time.zone.at(random_epoch))
    stub_request(:get, url).to_return(stub_response)
  end

  after do
    Timecop.return
  end

  describe "#response" do
    it "does something" do
      expect(subject.response.code).to eq(200)
    end
  end

  describe "#body" do
    it "is the request body" do
      expect(subject.body).to eq(body)
    end
  end

  describe "#body_as_hash" do
    let(:body) { yaml }

    it "return a hash" do
      expect(subject.body_as_hash).to be_a(Hash)
    end

    it "has the content from simple file" do
      expect(subject.body_as_hash).to eq({ "this" => { "foo" => "bar" } })
    end
  end
end
