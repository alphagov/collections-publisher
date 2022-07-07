# Merging of Mainstream Browse Topics into Specialist Topics

## Status

Proposed

## Context

GOV.UK currently maintains 3 topic systems that represent a navigational structure for users. The Topic Taxonomy (schema: `taxon`), Specialist Topics (schema: `topic`) and Mainstream Browse (schema: `mainstream_browse_page`).

Mainstream Browse is the oldest topic system. Documents are tagged to Mainstream Browse topics by GDS Editors in [Content Tagger](https://github.com/alphagov/content-tagger) or [Publisher](https://github.com/alphagov/publisher). Tagging adds a Mainstream Browse breadcrumb. For the tagged content to be visible on the Mainstream Browse topic page, a further curation step is required in collections publisher.

The Specialist Topic system is concerned with specialist content, and is the only topic system integrated with email notifications. Government publishers are able to tag content to the Specialist Topic system in Whitehall. Doing so adds a Specialist Topic breadcrumb to the page, and results in that content appearing on some Specialist Topic pages.

The most recent topic system is the Topic Taxonomy, which was intended to replace Specialist Topics and Mainstream Browse. Whilst tagging a piece of content to this system will provide navigational elements if the content is not tagged to other topic systems, the Topic Taxonomy is not viewed as a navigational system. It is primarily concerned with search, and the filtering of search results.

#### Problems

* There is no connection between Mainstream Browse and Specialist Topics, i.e. users who navigate to a Mainstream Browse page are siloed away from Specialist Topic content.
* The result of tagging to these taxonomies is unclear to government publishers.

#### Previous attempts to solve these problems

There have been a number of previous plans and attempts to merge these trees.

* See [this RFC](https://github.com/alphagov/govuk-rfcs/pull/119) that considered merging Specialist Topics and Mainstream Browse into the Topic Taxonomy.

## Decision

For this work, the #navigation-and-presentation team has decided to merge the two navigational topic systems (Mainstream Browse and Specialist Topics), and ignore the Topic Taxonomy.

We initially planned to map each Mainstream Browse topic to an equivalent Specialist Topic, so that content tagged to the Mainstream Browse topic would become tagged to its equivalent in the Specialist Topic tree. But creating this mapping would have been overly complex and slow. For example [Benefits](https://www.gov.uk/browse/benefits) (a Mainstream Browse topic) and [Benefits and Credits](https://www.gov.uk/topic/benefits-credits) (a Specialist topic) may seem equivalent, but there is no parity in the content linked. There's also no strict mapping between levels, for example Level 1 in mainstream may be Level 2 for one Specialist topic area, but there may be a Level 2 to Level 2 mapping in another.

We now intend to merge the trees without a mapping. When a Mainstream Browse topic is imported into the Specialist Topic tree it will become a new Specialist Topic. This will mean that there are similarly named topics - for example we will have a Benefits topic, as well as a Benefits and Credits topic. So once the trees are merged there will be a piece of work to curate and deduplicate.

### How will we merge the two systems

Our intention is to merge the trees without any visible changes for users or publishers. We do not want publishers to tag to these new 'browse topics', and we do not want users to be able to navigate to new browse topic pages until we have completed the curation of the extended Specialist Topic tree. An important implementation detail: New browse topics will contain a reference to their parent mainstream browse topic.

#### Overview of roll out plan

![Screenshot](/docs/merging-topics-plan.png)

##### Prepare
* Add code to hide new browse topics from tagging interfaces in publishing applications, and navigational elements in frontend applications.
* Create a redirect in Collections so new browse topic pages are not findable.
* Implement autotagging, so that a piece of content being tagged to a Mainstream Browse page is also tagged to the related new browse topic in the Specialist Topic tree.

##### Merge
* Import the Mainstream Browse topic tree into the Specialist Topic tree on production (after testing the task on integration first).
* We will be leaving behind some Mainstream Browse specific data, such as `active_top_level_browse_page`, `second_level_browse_pages`, `top_level_browse_pages`.

##### Tag content to new tree
* Run a rake task, that for a given new browse topic, fetches all content tagged to the parent mainstream browse topic, and tags it to the new browse topic. And reciprocally, adds the content to the links of the new browse topic.

## Consequences

Once these trees are merged, the second phase of this work will be to curate and de-duplicate the tree. Currently the Specialist Topic curation panel in this application does not support untagging content to a specialist topic. Instead, it links out to Content Tagger where the tags can be amended. However Content Tagger does not support the tagging or untagging of Whitehall content to Specialist Topics, it is necessary to do that via the Whitehall admin UI. This limitation might make the process of curating the tree painful - so we are working on the functional requirements of an improved topic curation UI in this application.

Once a branch of the new browse tree has been curated, we will update [Collections](https://github.com/alphagov/collections) to build the browse page from the new browse topic content item instead of from the original mainstream browse content item, and then archive the mainstream browse page.

The point at which we will allow tagging to this new tree is still up for discussion.
