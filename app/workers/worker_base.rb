class WorkerBase
  include Sidekiq::Worker

  def self.perform_async(*args)
    args << { request_id: GdsApi::GovukHeaders.headers[:govuk_request_id] }
    super(*args)
  end

  def perform(*args)
    last_arg = args.last

    if last_arg.is_a?(Hash) && last_arg.keys == ["request_id"]
      args.pop
      request_id = last_arg["request_id"]
      GdsApi::GovukHeaders.set_header(:govuk_request_id, request_id)
    end

    call(*args)
  end
end
