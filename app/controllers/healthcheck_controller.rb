class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    healthcheck = GovukHealthcheck.healthcheck([
      GovukHealthcheck::SidekiqRedis,
      GovukHealthcheck::ActiveRecord,
    ])
    render json: healthcheck
  end
end
