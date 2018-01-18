# Changing the slug of a Tag or Topic

This will update the slug in the collections-publisher database,
then send it to Publishing API. The API will create a redirect
from the old URL to the new URL, and Rummager will pick the change
up from the queue and update the search index.

On a Rails console:

```ruby
topic = Topic.find_by(slug: 'regulation')
topic.update_column :slug, 'social-housing-regulation-england'
topic.reload
PublishingAPINotifier.notify topic
```

There is a validation that prevents slugs being changed by content
designers that was added before Publishing API handled all this. It
could be removed and the ability to maange these given to content
designers.
