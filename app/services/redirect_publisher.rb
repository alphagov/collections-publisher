class RedirectPublisher
  def republish_redirects
    RedirectItem.all.each do |item|
      presenter = RedirectItemPresenter.new(item)
      PublishingApiContentWriter.write(presenter)
    end
  end
end
