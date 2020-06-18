module CoronavirusPages
  class Configuration
    def self.page(key)
      all_pages[key.to_sym]
    end

    def self.all_pages
      {
        landing:
          {
            name: "Coronavirus landing page",
            content_id: "774cee22-d896-44c1-a611-e3109cce8eae".freeze,
            raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml".freeze,
            base_path: "/coronavirus",
            github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_landing_page.yml",
          },
        business:
          {
            name: "Business support page",
            content_id: "09944b84-02ba-4742-a696-9e562fc9b29d".freeze,
            raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml".freeze,
            base_path: "/coronavirus/business-support",
            github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_business_page.yml",
          },
        education:
          {
            name: "Education page",
            content_id: "b350e61d-1db9-4cc2-bb44-fab02882ac25".freeze,
            raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_education_page.yml".freeze,
            base_path: "/coronavirus/education-and-childcare",
            github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_education_page.yml",
          },
        employees:
          {
            name: "Worker page",
            content_id: "5ebf285a-9165-476c-be90-66b9729f50da".freeze,
            raw_content_url: "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_worker_page.yml".freeze,
            base_path: "/coronavirus/worker-support",
            github_url: "https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_worker_page.yml",
          },
      }
    end
  end
end
