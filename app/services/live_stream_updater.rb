class LiveStreamUpdater
  attr_reader :object

  def initialize
    @content_item = fetch_live_content_item
    @url = live_url
    @object = live_stream_object
  end

  def update?
    update_content_item.try(:code) == 200
  end

  def publish?
    publish_content_item.try(:code) == 200
  end

private

  attr_reader :live_stream, :content_item, :url
  attr_writer :object

  def live_stream_object
    LiveStream.first_or_create(url: url)
  end

  def live_url
    if content_item.has_key?("details")
      content_item["details"]["live_stream"]["video_url"]
    end
  end

  def update_content_item
    with_longer_timeout do
      begin
        Services.publishing_api.put_content(landing_page_id, live_stream_payload)
      rescue GdsApi::HTTPErrorResponse
        object.update(url: url)
      end
    end
  end

  def publish_content_item
    with_longer_timeout do
      begin
        Services.publishing_api.publish(landing_page_id, "minor")
      rescue GdsApi::HTTPErrorResponse
        object.update(url: live_url)
      end
    end
  end

  def fetch_live_content_item
    begin
      content = Services.publishing_api.get_content(landing_page_id)
      content.to_hash
    rescue GdsApi::HTTPErrorResponse
      {}
    end
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
