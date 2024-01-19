class RedirectPublisher
  def republish_redirects
    RedirectItem.all.find_each do |item|
      presenter = RedirectItemPresenter.new(item)
      ContentItemPublisher.new(presenter, update_type: "republish").send_to_publishing_api
    end
  end
end
