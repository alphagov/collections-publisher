class ListRepublisher
  def republish_tags(tags)
    done = 0
    tags.find_each do |tag|
      next if tag.lists.blank?

      update_groups(tag)
      republish_tag(tag)

      done += 1

      if (done % 100).zero?
        log "#{done} completed..."
      end
    end

    log "All done"
  end

private

  def update_groups(tag)
    groups = GroupsPresenter.new(tag).groups
    tag.update!(published_groups: groups, dirty: false)
  end

  def republish_tag(tag)
    with_retry do
      presenter = TagPresenter.presenter_for(tag)
      begin
        ContentItemPublisher.new(presenter, update_type: "republish").send_to_publishing_api
      rescue GdsApi::TimedOutException, Timeout::Error => e
        log "#{tag.content_id} republish tag with groups failed"
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
    Rails.logger.info(string)
  end
end
