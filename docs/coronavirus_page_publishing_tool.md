## Coronavirus Publishing Tool

There are currently three coronavirus hub pages(/coronavirus/business-support, /coronavirus/education-and-childcare, /coronavirus/worker-support), and a coronavirus landing page. As we approached lockdown, a basic publishing interface was required at short notice. This is how it works:

1. Content is added to the relevant yaml file in the [govuk-coronavirus-content](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content) repository.
2. Content editor with Coronavirus editor signon permissions visits [Coronavirus pages](https://collections-publisher.publishing.service.gov.uk/coronavirus) tab of collections publisher.
3. Selects which page to publish.
4. Clicking update draft and publish buttons, fetches the yaml file, parses it, and sends it to publishing api as JSON.
5. Collections renders the page by reading from this updated content item.

### First iteration of new tool

In order to reduce the load on content designers and supporting developers, a better publishing tool was required that would remove the need to make content changes via github. The first iteration of this tool was to move the accordion content out of the yaml file in govuk-coronavirus-content, and into the collections publisher database. This means it can be edited from collections publisher directly via a friendlier UI. **NB the content for the rest of the page must still be edited via the steps above.**

![Screenshot of sections publishing tool](/docs/screenshot-coronavirus-edit-page.png)

#### Content editable from collections publisher:

- [ ] title
- [ ] meta_description
- [ ] page_header
- [ ] header_section
- [ ] announcements
- [ ] nhs_banner
- [ ] find_help
- [ ] sections_heading
- [x] sections (aka accordions)
- [ ] statistics_section
- [ ] topic_section
- [ ] notifications
- [ ] live_stream
- [x] live_stream:video_url and date
- [ ] special_announcements_schema

### Future iterations

Future iterations will be needed to move the content that remains in the govuk-coronavirus-content repository out of the yaml file, and into collections publisher.

### How to create a new hub page

1. Create a new yaml file following the format of those currently in [govuk-coronavirus-content](https://github.com/alphagov/govuk-coronavirus-content/tree/master/content) repository, and add page content.
2. Add a basic page configuration to [this file](app/services/coronavirus_pages/configuration.rb) in Collections Publisher.
3. Visiting the Coronavirus page tab of collections publisher will [create a coronavirus page model](https://github.com/alphagov/collections-publisher/blob/bbc667e5ab1c76fc0038fb4c0b14434b6ad3283c/app/controllers/coronavirus_pages_controller.rb#L50) based on the configuration.
4. The result will be two new links are be created on the [index page](https://collections-publisher.publishing.service.gov.uk/coronavirus):
  - Edit the \<new hub> page accordion
  - Publish \<new hub> page
5. The Edit link can be used to populate the accordion section on the page.
6. The Publish link can be used to pull in the content added to the yaml file created in step one, and send it to publishing api.
