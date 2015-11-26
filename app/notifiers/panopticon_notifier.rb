class PanopticonNotifier
  def self.create_tag(tag_presenter)
    tag_hash = tag_presenter.render_for_panopticon

    panopticon.create_tag(tag_hash)
  end

  def self.update_tag(tag_presenter)
    tag_hash = tag_presenter.render_for_panopticon

    panopticon.put_tag(tag_hash[:tag_type], tag_hash[:tag_id], tag_hash)
  end

  def self.publish_tag(tag_presenter)
    tag_hash = tag_presenter.render_for_panopticon

    panopticon.publish_tag(tag_hash[:tag_type], tag_hash[:tag_id])
  end

  def self.panopticon
    Services.panopticon
  end
end
