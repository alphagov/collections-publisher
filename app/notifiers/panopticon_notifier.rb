class PanopticonNotifier
  def self.create_tag(tag_presenter)
    tag_hash = tag_presenter.render_for_panopticon

    panopticon.create_tag(tag_hash)
  end

  def self.update_tag(tag_presenter)
    tag_hash = tag_presenter.render_for_panopticon

    panopticon.put_tag(tag_hash[:tag_type], tag_hash[:tag_id], tag_hash)
  end

private
  def self.panopticon
    CollectionsPublisher.services(:panopticon)
  end
end
