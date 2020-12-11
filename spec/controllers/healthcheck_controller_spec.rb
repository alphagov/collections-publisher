require "rails_helper"

RSpec.describe HealthcheckController, type: :controller do
  describe "GET /healthcheck" do
    before do
      get :index
    end

    it "returns a 200 HTTP status" do
      expect(response).to have_http_status(:ok)
    end

    it "includes a status in the response body" do
      expect(JSON.parse(response.body)).to have_key("status")
    end

    it "checks for database connectivity" do
      json = JSON.parse(response.body)
      expect(json["checks"]).to include("database_connectivity")
    end

    it "checks for redis connectivity" do
      json = JSON.parse(response.body)
      expect(json["checks"]).to include("redis_connectivity")
    end
  end
end
