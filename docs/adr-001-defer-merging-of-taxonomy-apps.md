# Decision record: Defer Merging of Taxonomy Apps

Created: 2016-02-03

## Context

Team Finding Things is currently working on a new taxonomical structure for
content on GOVUK, in order to make it easier for users to find relevant
information. Broadly speaking, this involves three distinct, parallel streams of
work -
* defining the taxonomy itself.
* designing a tagging interface to easily assign content to an appropriate
  taxonomical category.
* code/architectural changes to support the above in the context of the V2
  publishing API.

At present, we have three taxonomical structures on GOVUK:

* Mainstream browse pages (legacy, see https://www.gov.uk/browse)
* Topic pages (legacy, see https://www.gov.uk/topic)
* Taxons (a work in progress - at time of writing no representation of these is
  available in Production).

Creation of these structures is handled entirely in the `collections-publisher`
application. This app also includes functionality to curate/group these
structures, i.e. - setting certain topics as subtopics, or assigning one taxon
as the parent of another.

The taxonomy definition work is underway, and we've recently introduced
functionality to make the resulting taxon data available via API calls to the
content store. This is so that our designers have access to useful test data in
their interface prototyping work.  Enabling this involved introducing a 'taxon'
content type. We decided to place the creation/editing interface for
this content type in `collections-publisher`, because of the conceptual
similarity to topics and browse pages.

In addition (and earlier on, before taxons became a type of content on GOVUK),
architectural changes to support the V2 publishing API and its associated
publishing pipeline prompted the creation of the
[`content-tagger`](https://github.com/alphagov/content-tagger) app. This is
intended to be a single interface through which all content on GOVUK can be
tagged. It currently supports tagging with mainstream browse pages, topics, and
organisations. We will inevitably need to tag content to specific taxons, so
`content-tagger` will soon be updated to provide this functionality as well.

The structure and responsibilities of these two apps were established quickly
with minimal communication across the team. An architectural discussion was held
on 2016-02-02 to clarify their roles and to decide whether or not to merge or
move functionality. This latter question was raised due to some
confusion around the presence of taxonomy-related code in two different apps.
This was exacerbated by the fact that bulk-creation of taxons and the mapping of
these to content items is a piece of functionality that currently exists as a
set of scripts sitting solely in `content-tagger`.

## Decision

We've decided to defer merging these applications or making any move to isolate
taxonomy-specific functionality into a single, distinct app.

The new taxonomical structure will eventually supersede both mainstream browse
pages and topics as a means of navigating and discovering content. When that
happens, there may be value (simplicity, ease of maintenance) in having a single
app which allows creation of taxons, creation of hierarchies made up of these
taxons, and tagging of content to taxons. Merging the apps now is a non-trivial
undertaking and the benefits of doing so don't outweigh the time investment.
This is particularly the case given the higher priority pieces of work we have
planned in the near future - migrating all apps across GOVUK to conform to the
new publishing/tagging architecture, and deciding how to implement a shared,
uniform tagging UI in both `content-tagger` and the publishing apps.

## Status

Accepted, 2016-02-03.

## Consequences

* Taxon creation/editing will be handled by `collections-publisher`, while
  tagging of content to specific taxons will be handled by content-tagger.
* With taxon creation/editing staying in `collections-publisher`, it's arguable
  that the app has evolved to a point where its name is no longer particularly
  indicative of what it does. This is a source of confusion for anyone
  attempting to understand how the app fits into GOVUK's architecture. A
  renaming may well be required in the not-too-distant future.
