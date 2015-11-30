# Collections Publisher

The Collections Publisher publishes browse pages and topic pages.

The content created is served by the [Collections app](https://github.com/alphagov/collections).

![Screenshot of Collections Publisher](docs/screenshot.jpg)

## Nomenclature

See the [README of collections frontend](https://github.com/alphagov/collections).

## Technical documentation

This is a Ruby on Rails application for internal use, with no public facing aspect. It retrieves information about which content is tagged to a topic or browse page from Rummager and publishes Curated lists to the Content store.

### Dependencies

- [alphagov/content-store](https://github.com/alphagov/content-store) -
  (write request only) to store information about the topic
  groupings for Collections API and other apps to use.
- [alphagov/rummager](https://github.com/alphagov/rummager) -
  to index topics and mainstream browse pages, and to fetch documents that have
  been tagged to topics and mainstream browse pages by publisher tools.


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

### Dumping and restoring the database

To dump and restore a copy of the development database, there is a rake task available [here](https://gist.github.com/stephen-richards/b78f2637206cc22eacd5)

## Licence

[MIT License](LICENSE.txt)
