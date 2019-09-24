class TagRepublisher
  def republish_tags(tags)
    log "Sending #{tags.count} tags to the publishing-api"

    done = 0
    tags.find_each do |tag|
      republish_tag(tag)

      done += 1

      if (done % 100).zero?
        log "#{done} completed..."
      end
    end

    log "Done: #{done} tags sent to publishing-api."

    log "Sending root browse page to publishing-api"
    with_retry do
      presenter = RootBrowsePagePresenter.new("state" => "published")
      ContentItemPublisher.new(presenter, update_type: "republish").send_to_publishing_api
    end

    log "Sending root topic to publishing-api"
    with_retry do
      presenter = RootTopicPresenter.new("state" => "published")
      ContentItemPublisher.new(presenter, update_type: "republish").send_to_publishing_api
    end

    log "All done"
  end

private

  def republish_tag(tag)
    with_retry do
      presenter = TagPresenter.presenter_for(tag)
      begin
        ContentItemPublisher.new(presenter, update_type: "republish").send_to_publishing_api
      rescue GdsApi::TimedOutException, Timeout::Error => e
        log "#{tag.content_id} republish failed"
        raise e
      end
    end
  end

  def with_retry
    retries = 0

    begin
      yield
    rescue GdsApi::TimedOutException, Timeout::Error
      retries += 1
      if retries <= 3
        log "Timeout: retry #{retries}"
        sleep 0.5
        retry
      end
    end
  end

  def publishing_api
    Services.publishing_api
  end

  def log(string)
    puts string
    Rails.logger.info(string)
  end
end
