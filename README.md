# Collections publisher

The `collections-publisher` publishes certain collection and tag formats requiring
complicated UIs.  Its initial use will be "curated lists" for browse topics.

## Technical documentation

This is a Ruby on Rails application for internal use, with no public facing
aspect. It retrieves topic information from the Content API and publishes
Curated lists to the Content store.

### Dependencies

- [alphagov/govukcontent-api](https://github.com/alphagov/govuk_contentapi) -
  (read request only) to fetch information about the available topics.
- [alphagov/content-store](https://github.com/alphagov/content-store) -
  (write request only) to store information about the topic
  groupings for Collections API and other apps to use.

### Running the application

Run `bundle exec rails server`. Ensure the dependencies are satisfied before
running. If you are using the development VM, run the app using `bowl
collections-publisher` from within the `govuk/development` dir.

If you are running locally, ensure that the dependencies are available at
`http://content-store.dev.gov.uk` and `http://content-api.dev.gov.uk`.

#### Creating the mysql user for development

The database.yml for this project is checked into source control so
you'll need a local user with credentials that match those in
database.yml.

`mysql> grant all on `collections_publisher\_%`.* to collections_pub@localhost identified by 'collections_publisher';`

### Running the test suite

The test suite includes testing against
[govuk-content-schemas](http://github.com/alphagov/govuk-content-schemas), so
you will need a copy of this repo on your file system. By default this should
be in a sibling directory to your project. Alternatively, you can specify their
location with the `GOVUK_CONTENT_SCHEMAS_PATH` environment variable.

To run the full test suite: `bundle exec rake`.

To run just the schema tests: `bundle exec rake spec:schema`.

## Licence

[MIT License](LICENSE)
