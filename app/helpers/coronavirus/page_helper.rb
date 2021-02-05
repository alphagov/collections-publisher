module Coronavirus
  module PageHelper
    def page_type(page)
      page.topic_page? ? "Coronavirus landing page" : "Coronavirus hub page"
    end

    def formatted_title(page)
      page.topic_page? ? "Coronavirus (COVID-19)" : page.title
    end
  end
end
