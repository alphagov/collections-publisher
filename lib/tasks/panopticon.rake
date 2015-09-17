namespace :panopticon do
  desc "Register application metadata with panopticon"
  task :register => [:environment] do
    Tag.published.find_each do |tag|
      PanopticonNotifier.update_tag(TagPresenter.presenter_for(tag))
    end
  end
end
