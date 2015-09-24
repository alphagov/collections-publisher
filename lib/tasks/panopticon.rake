namespace :panopticon do
  desc "Republish all tags to panopticon"
  task :republish_tags => [:environment] do
    Tag.where(state: %w[published draft]).find_each do |tag|
      PanopticonNotifier.update_tag(TagPresenter.presenter_for(tag))
    end
  end
end
