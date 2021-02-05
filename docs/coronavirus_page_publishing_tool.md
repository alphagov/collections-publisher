## Coronavirus Publishing Tool

There are currently three coronavirus hub pages(/coronavirus/business-support, /coronavirus/education-and-childcare, /coronavirus/worker-support), and a coronavirus landing page. The content for these is managed by a combination of CMS functionality within collections-publisher and the use of a yaml file stored in the [govuk-coronavirus-content](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content) repository.

### How to create a new hub page

1. Create a new yaml file following the format of those currently in [govuk-coronavirus-content](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content) repository, and add page content.
2. Add a basic page configuration to [this file](app/services/coronavirus/pages/configuration.rb) in Collections Publisher.
3. Visiting the Coronavirus page tab of collections publisher will create a coronavirus page model based on the configuration using the service Coronavirus::Pages::ModelBuilder.
4. As a result two new links will be created on the [index page](https://collections-publisher.publishing.service.gov.uk/coronavirus):
  - Edit \<new hub> page accordions
  - Edit something else on the \<new hub> page
5. The **Edit \<new hub> page accordions** link can be used to populate the accordion section on the page.
6. The **Edit something else on the \<new hub> page** link can be used to pull in the content added to the yaml file created in step one, merge that content with the page sub section data, and send it to publishing api.
