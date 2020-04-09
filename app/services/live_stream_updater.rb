class LiveStreamUpdater
  def initialize(object, state = nil)
    @object = object
    @state = state
    @content_item = fetch_live_content_item
  end

  def updated?
    update_object_and_content_item.try(:code) == 200
  end

  def published?
    publish_content_item.try(:code) == 200
  end

  def resync
    states_in_sync? ? object : object.toggle(:state)
  end

private

  attr_reader :state, :live_stream, :content_item
  attr_accessor :object

  def states_in_sync?
    live_state == object.state
  end

  def live_state
    content_item["details"]["live_stream_enabled"]
  end

  def update_object_and_content_item
    if object.update(state: state)
      update_content_item
    end
  end

  def update_content_item
    with_longer_timeout do
      begin
        response =
          Services.publishing_api.put_content(landing_page_id, live_stream_payload)
        response.code == 200 ? response : object.toggle(:state)
      rescue GdsApi::HTTPClientError
        object.toggle(:state)
      end
    end
  end

  def publish_content_item
    with_longer_timeout do
      begin
        response =
          Services.publishing_api.publish(landing_page_id, "minor")
        response.code == 200 ? response : object.toggle(:state)
      rescue GdsApi::HTTPClientError
        object.toggle(:state)
      end
    end
  end

  def fetch_live_content_item
    content = Services.publishing_api.get_content(landing_page_id)
    JSON.parse(content.raw_response_body)
  end

  def presenter
    CoronavirusPagePresenter.new(content_item["details"], "/coronavirus")
  end

  def live_stream_payload
    presenter.payload.merge(
      {
        "title" => "Coronavirus (COVID-19): what you need to do",
        "description" => content_item["description"],
      },
    )
  end

  def landing_page_id
    "774cee22-d896-44c1-a611-e3109cce8eae"
  end

  def with_longer_timeout
    prior_timeout = Services.publishing_api.client.options[:timeout]
    Services.publishing_api.client.options[:timeout] = 10

    begin
      yield
    ensure
      Services.publishing_api.client.options[:timeout] = prior_timeout
    end
  end
end
