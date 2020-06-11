require "rails_helper"

RSpec.describe YamlFetcher do
  let(:url) { Faker::Internet.url(host: "example.com") }
  let(:yaml) { File.read(Rails.root.join("spec/fixtures/simple.yml")) }
  let(:body) { "something" }
  let(:stub_response) { { body: body } }

  subject { described_class.new(url) }

  before { stub_request(:get, url).to_return(stub_response) }

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
      expect(subject.body_as_hash).to eq({ this: { foo: "bar" } })
    end
  end

  describe "#success?" do
    it "is true if all OK" do
      expect(subject.success?).to be(true)
    end

    context "connection failure" do
      let(:stub_response) { { body: body, status: 401 } }

      it "is false" do
        expect(subject.success?).to be(false)
      end
    end
  end
end
