module CoronavirusPageHelper
  def page_type(coronavirus_page)
    coronavirus_page.topic_page? ? "Topic page" : "Sub-topic page"
  end
end
