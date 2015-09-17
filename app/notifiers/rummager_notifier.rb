class RummagerNotifier
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def notify
    return if tag.draft?

    Services.rummager.add_document(
      'edition',
      presenter.base_path,
      presenter.render_for_rummager
    )
  end

private

  def presenter
    @presenter ||= TagPresenter.presenter_for(tag)
  end
end
