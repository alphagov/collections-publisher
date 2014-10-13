class PanopticonNotifier
  def self.create_tag(tag_presenter)
    tag_hash = tag_presenter.render_for_panopticon

    panopticon = CollectionsPublisher.services(:panopticon)
    panopticon.create_tag(tag_hash)
  end
end
