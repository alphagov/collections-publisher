module MainstreamBrowsePageHelper
  def browse_page(name, parent=nil)
    create(:mainstream_browse_page,
           title: name,
           parent: parent)
  end
end

RSpec.configure do |config|
  config.include MainstreamBrowsePageHelper
end
