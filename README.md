# Collections Publisher

This app is used by GDS and some departmental editors. It can publish:

- [/browse pages](https://www.gov.uk/browse/births-deaths-marriages/register-offices)
- [/topic pages](https://www.gov.uk/topic/business-enterprise/export-finance)
- [step by step pages](https://www.gov.uk/learn-to-drive-a-car) and [step by step sidebar navigation](https://www.gov.uk/driving-eyesight-rules)
- [coronavirus pages](docs/coronavirus_page_publishing_tool.md)

These pages are then served by the [collections app](https://github.com/alphagov/collections). It is also used to curate pages tagged to a topic or browse page into "curated lists", instead of a single 'A-Z' list, as the following screenshots illustrate.

![Screenshot of curated and non-curated pages](docs/screenshot-curated-topics.png)

## Nomenclature

See the [README of collections frontend](https://github.com/alphagov/collections).

## Technical documentation

This is a Ruby on Rails application.

This application uses the [sidekiq](http://sidekiq.org/) message queue for background work (mainly publishing to the Publishing API).

### Dependencies

- [alphagov/publishing-api](https://github.com/alphagov/publishing-api) -
  - used for the publishing workflow of `mainstream_browse_page`s, `topic`s, curated lists and `step_by_step_page`s.
  - Publishing API sends data onto [Rummager](https://github.com/alphagov/rummager) for search indexing `topic`, `mainstream_browse_page` and `step_by_step_page` pages.

### Running the test suite

The test suite includes testing against
[govuk-content-schemas](http://github.com/alphagov/govuk-content-schemas), so
you will need a copy of this repo on your file system. By default this should
be in a sibling directory to your project. Alternatively, you can specify their
location with the `GOVUK_CONTENT_SCHEMAS_PATH` environment variable.

To run the test suite:

```
bundle exec rake
```

## Licence

[MIT License](LICENSE.txt)
