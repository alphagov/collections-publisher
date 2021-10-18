module Coronavirus::Pages
  class Configuration
    def self.page
      {
        name: "Coronavirus landing page",
        content_id: "774cee22-d896-44c1-a611-e3109cce8eae".freeze,
        raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml".freeze,
        base_path: "/coronavirus",
        github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_landing_page.yml",
        state: "published",
      }
    end
  end
end
