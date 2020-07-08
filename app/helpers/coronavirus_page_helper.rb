module CoronavirusPageHelper
  def page_type(coronavirus_page)
    coronavirus_page.topic_page? ? "Topic page" : "Sub-topic page"
  end

  def formatted_title(coronavirus_page)
    coronavirus_page.topic_page? ? "Coronavirus (COVID-19)" : coronavirus_page.title
  end
end
