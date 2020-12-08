class HealthcheckController < ApplicationController
  def index
    healthcheck = GovukHealthcheck.healthcheck([
      GovukHealthcheck::SidekiqRedis,
      GovukHealthcheck::ActiveRecord,
    ])
    render json: healthcheck
  end
end
