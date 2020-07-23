module CoronavirusPageHelper
  def page_type(coronavirus_page)
    coronavirus_page.topic_page? ? "Coronavirus landing page" : "Coronavirus hub page"
  end

  def formatted_title(coronavirus_page)
    coronavirus_page.topic_page? ? "Coronavirus (COVID-19)" : coronavirus_page.title
  end
end
