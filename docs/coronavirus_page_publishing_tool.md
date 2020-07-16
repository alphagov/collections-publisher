## Coronavirus Publishing Tool

There are currently three coronavirus hub pages(/coronavirus/business-support, /coronavirus/education-and-childcare, /coronavirus/worker-support), and a coronavirus landing page. As we approached lockdown, a basic publishing interface was required at short notice. This is how it works:

1. Content is added to the relevant yaml file in the [govuk-coronavirus-content](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content) repository.
2. A user with "Coronavirus editor" permissions) visits [Coronavirus pages](https://collections-publisher.publishing.service.gov.uk/coronavirus) tab of collections publisher.
3. Selects which page to publish.
4. Clicking update draft and publish buttons, fetches the yaml file, parses it, and sends it to publishing api as JSON.
5. Collections renders the page by reading from this updated content item.

### First iteration of new tool

In order to reduce the load on content designers and supporting developers, a better publishing tool was required that would remove the need to make content changes via github. The first iteration of this tool was to move the accordion content out of the yaml file in govuk-coronavirus-content, and into the collections publisher database. This means it could be edited from collections publisher directly via a friendlier UI. **NB the content for the rest of the page would still be edited via the steps above.**

![Screenshot of sections publishing tool](/docs/screenshot-coronavirus-edit-page.png)

#### Content editable from collections publisher:

See the govuk-coronavirus-content [yaml file](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content/coronavirus_landing_page.yml) for comparison

- [ ] title
- [ ] meta_description
- [ ] page_header
- [ ] header_section
- [ ] announcements
- [ ] nhs_banner
- [ ] find_help
- [ ] sections_heading
- [x] sections (called accordions by designers, stored as subsections)
- [ ] statistics_section
- [ ] topic_section
- [ ] notifications
- [ ] live_stream
- [x] live_stream:video_url and date
- [ ] special_announcements_schema

### Future iterations

Future iterations will be needed to move the content that remains in the govuk-coronavirus-content repository out of the yaml file, and into collections publisher.

### Models and naming

The term accordion is used by content designers to describe this part of the page:

![Screenshot of accordions](/docs/coronavirus-page-accordion.png)

The accordion content is stored in the database as a SubSection:

- A CoronavirusPage has many SubSections.

- Each SubSection has a title (eg Funding and Support) and content (stored as markdown).

### How to create a new hub page

1. Create a new yaml file following the format of those currently in [govuk-coronavirus-content](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content) repository, and add page content.
2. Add a basic page configuration to [this file](app/services/coronavirus_pages/configuration.rb) in Collections Publisher.
3. Visiting the Coronavirus page tab of collections publisher will create a coronavirus page model based on the configuration using the service CoronavirusPages::ModelBuilder.
4. As a result two new links will be created on the [index page](https://collections-publisher.publishing.service.gov.uk/coronavirus):
  - Edit the \<new hub> page accordion
  - Publish \<new hub> page
5. The Edit link can be used to populate the accordion section on the page.
6. The Publish link can be used to pull in the content added to the yaml file created in step one, merge that content with the page sub section data, and send it to publishing api.
