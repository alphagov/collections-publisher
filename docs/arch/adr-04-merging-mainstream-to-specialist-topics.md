# Merging of Mainstream Topics into Specialist Topics

## Status

Accepted

## Context

GOV.UK currently maintains 2 separate topic trees that represent a navigational structure for users. Mainstream Browse is the oldest and considered legacy. Specialist Topics are newer but need tidying up and do not power breadcrumbs.

Previous attempts to merge the two stalled (since 2015).

The newest tree, Taxonomy, does not affect navigation and is treated as a purely metadata type categorisation tree and is ignored by this work.

There is no connection between Mainstream Browse and the Specialist Topics. Users who navigate Mainstream Browse are siloed away from Specialist Topics content. It also causes a confusing and inconsistent way for tagging and curating content.

## Decision

We initially planned to map each Mainstream Browse Topic to an equivalent within the Specialist Topics tree. This would have been complex and difficult to even begin the merging of the two trees. 

For example Benefits (mainstream) and Benefits and Credits (specialist) may seem equivalent, but there is no parity in the content linked. There's also no strict mapping between levels, as in Level 1 in mainstream may be Level 2 in specialist for one topic area, but there may be a L2 to L2 mapping in another. 

If we were to tidy up as we merged, this would be a very slow and difficult process to manage.

But deeper discussion brought us to realise that we may not need to concern ourselves now about there being overlaps, allowing us to naively merge the trees and tidy up the data in one place instead. 

## Consequences

Once we've ported the topics across, we would have to periodically (interval TBD) sync data across from Mainstream Browse to Specialist Topics:

* keep all creation logic in Collections Publisher
* Create and run rake task to create new topics based on existing browse pages, any new pages created from this are hidden (schema change).
* Have logic to do this whenever a new Browse page is added in collections publisher
* Modify patch links (tagging) behaviour to patch a relevant Topic whenever a Browse page is tagged in the two apps that allow it (Tagger and Publisher)

We would have to set our apps to ignore the newly ported topics for a time, while we check that the data is workable and that we can affect changes to apps to switch over, and update our tagging tools and publishing apps.

Ultimately we want to be able to allow content specialists to curate one structure within one place (or just fewer than we currently have).