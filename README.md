# Collections Publisher

The Collections Publisher publishes browse pages and topic pages.

The content created is served by the [Collections app](https://github.com/alphagov/collections).

![Screenshot of Collections Publisher](docs/screenshot.jpg)

## Nomenclature

See the [README of collections frontend](https://github.com/alphagov/collections).

## Technical documentation

This is a Ruby on Rails application for internal use, with no public facing aspect. It retrieves information about which content is tagged to a topic or browse page from the Content API and publishes Curated lists to the Content store.

### Dependencies

- [alphagov/govukcontent-api](https://github.com/alphagov/govuk_contentapi) -
  (read request only) to fetch information about the available topics.
- [alphagov/content-store](https://github.com/alphagov/content-store) -
  (write request only) to store information about the topic
  groupings for Collections API and other apps to use.


### Running the application

    bundle exec rails server

Ensure the dependencies are satisfied before
running. If you are using the development VM, run the app using bowler:

    cd /var/govuk/development && bundle exec bowl collections-publisher

### Running the test suite

The test suite includes testing against
[govuk-content-schemas](http://github.com/alphagov/govuk-content-schemas), so
you will need a copy of this repo on your file system. By default this should
be in a sibling directory to your project. Alternatively, you can specify their
location with the `GOVUK_CONTENT_SCHEMAS_PATH` environment variable.

To run the full test suite:

    bundle exec rake

To run just the schema tests:

    bundle exec rake spec:schema

## Licence

[MIT License](LICENSE.txt)
