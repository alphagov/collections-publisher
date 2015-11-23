class TagRepublisher
  def republish_tags(tags)
    log "Sending #{tags.count} tags to the publishing-api"

    done = 0
    tags.find_each do |tag|
      republish_tag(tag)

      done += 1

      if done % 100 == 0
        log "#{done} completed..."
      end
    end

    log "Done: #{done} tags sent to publishing-api."

    log "Sending root browse page to publishing-api"
    with_retry do
      presenter = RootBrowsePagePresenter.new
      publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      publishing_api.publish(presenter.content_id, presenter.update_type) 
    end


    log "Sending root topic to publishing-api"
    with_retry do
      presenter = RootTopicPresenter.new
      publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      publishing_api.publish(presenter.content_id, presenter.update_type) 
    end

    log "All done"
  end

private

  def republish_tag(tag)
    with_retry do
      PublishingAPINotifier.new(tag).send_single_tag_to_publishing_api
    end
  end

  def with_retry
    retries = 0

    begin
      yield
    rescue GdsApi::TimedOutException, Timeout::Error => e
      retries += 1
      if retries <= 3
        log "Timeout: retry #{retries}"
        sleep 0.5
        retry
      end
      raise
    end
  end

  def publishing_api
    Services.publishing_api
  end

  def log(string)
    Rails.logger.info(string)
  end
end
