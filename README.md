# Collections publisher

The `collections-publisher` publishes certain collection and tag formats requiring
complicated UIs.  Its initial use will be "curated lists" for browse topics.

## Creating the mysql user for development

The database.yml for this project is checked into source control so
you'll need a local user with credentials that match those in
database.yml.

    mysql> grant all on `collections_publisher\_%`.* to collections_pub@localhost identified by 'collections_publisher';
