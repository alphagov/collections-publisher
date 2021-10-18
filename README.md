# Collections Publisher

This app is used by GDS and some departmental editors. It can publish:

- [/browse pages](https://www.gov.uk/browse/births-deaths-marriages/register-offices)
- [/topic pages](https://www.gov.uk/topic/business-enterprise/export-finance)
- [step by step pages](https://www.gov.uk/learn-to-drive-a-car) and [step by step sidebar navigation](https://www.gov.uk/driving-eyesight-rules)
- [coronavirus pages](https://www.gov.uk/coronavirus)

These pages are then served by the [collections app](https://github.com/alphagov/collections). It is also used to curate pages tagged to a topic or browse page into "curated lists", instead of a single 'A-Z' list, as the following screenshots illustrate.

![Screenshot of curated and non-curated pages](docs/screenshot-curated-topics.png)

## Nomenclature

See the [README of collections frontend](https://github.com/alphagov/collections).

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
bundle exec rake
```

### Further documentation

See the [docs/](docs/) directory for guidance and architectural decisions.

## Licence

[MIT License](LICENSE.txt)
