class WorkerBase
  include Sidekiq::Worker

  def self.perform_async(*args)
    args << govuk_headers
    super(*args)
  end

  def perform(*args)
    last_arg = args.last

    if last_arg.is_a?(Hash) && last_arg.keys.include?("request_id")
      args.pop
      request_id = last_arg["request_id"]
      authenticated_user = last_arg["authenticated_user"]
      GdsApi::GovukHeaders.set_header(:govuk_request_id, request_id)
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, authenticated_user)
    end

    call(*args)
  end

  def self.govuk_headers
    {
      request_id: GdsApi::GovukHeaders.headers[:govuk_request_id],
      authenticated_user: GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user],
    }
  end
end
