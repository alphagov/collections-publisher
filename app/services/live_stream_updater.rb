class LiveStreamUpdater
  attr_reader :object

  def initialize
    @object = live_stream_object
  end

  def update
    update_content_item.try(:code) == 200
  end

  def publish
    publish_content_item.try(:code) == 200
  end

private

  attr_writer :object

  def live_stream_object
    Coronavirus::LiveStream.first_or_create(url: live_url, formatted_stream_date: live_date)
  end

  def live_stream_content
    if live_content_item.key?("details")
      live_content_item["details"]["live_stream"]
    else
      {}
    end
  end

  def live_url
    live_stream_content["video_url"]
  end

  def live_date
    live_stream_content["date"]
  end

  def update_content_item
    with_longer_timeout do
      Services.publishing_api.put_content(landing_page_id, payload)
    rescue GdsApi::HTTPErrorResponse
      object.update!(url: live_url, formatted_stream_date: live_date)
    end
  end

  def publish_content_item
    with_longer_timeout do
      Services.publishing_api.publish(landing_page_id, "minor")
    rescue GdsApi::HTTPErrorResponse
      nil
    end
  end

  def live_content_item
    @live_content_item ||=
      begin
        content = Services.publishing_api.get_content(landing_page_id)
        content.to_hash
      rescue GdsApi::HTTPErrorResponse
        {}
      end
  end

  def presenter
    Coronavirus::CoronavirusPagePresenter.new(live_content_item["details"], "/coronavirus")
  end

  def payload
    presenter.payload.merge(
      {
        "title" => "Coronavirus (COVID-19): what you need to do",
        "description" => live_content_item["description"],
        "details" => live_content_item["details"].deep_merge(live_stream_payload),
      },
    )
  end

  def live_stream_payload
    {
      "live_stream" => {
        "video_url" => object.url,
        "date" => object.formatted_stream_date,
      },
    }
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
