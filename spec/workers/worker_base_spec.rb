require "rails_helper"

RSpec.describe WorkerBase do

  class MyWorker < WorkerBase
    def call(*args); end
  end

  describe "perform_async" do
    it "appends govuk headers to job arguments" do
      allow(GdsApi::GovukHeaders).to receive(:headers).and_return({
        govuk_request_id: "12345-67890",
        x_govuk_authenticated_user: "abcdef-09876",
      })

      expect(WorkerBase).to receive(:client_push)
        .with("class" => MyWorker,
              "args" => [
                "foo",
                { request_id: "12345-67890", authenticated_user: "abcdef-09876" }
              ])

      MyWorker.perform_async("foo")
    end
  end

  describe "perform" do
    it "populates govuk headers from job arguments" do
      MyWorker.new.perform(
        "foo",
        { "request_id" => "12345-67890", "authenticated_user" => "abcdef-09876" }
      )

      expect(GdsApi::GovukHeaders.headers[:govuk_request_id]).to eq("12345-67890")
      expect(GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user]).to eq("abcdef-09876")
    end
  end
end
