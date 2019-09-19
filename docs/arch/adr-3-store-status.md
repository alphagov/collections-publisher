# Storing the status of step-by-steps

Date: 2019-09-02

## Context

The "status" of a step-by-step is determined from data about the step-by-step, e.g. if there is a `draft_updated_at` date but not a `published_at` date, then it has a status of `draft` etc.

That worked until now, when there were only had 4 statuses:

* draft
* live
* scheduled
* unpublished changes

Implementing the 2i workflow will need the addition of least three more statuses:

* submitted for 2i
* in review
* 2i approved

This will make the code to determine the status from the surrounding information very complicated.

### What status information is needed?

As well as knowing what part of the 2i workflow a step-by-step is in, the step-by-step also needs to know if it has been previously published. This is so that the correct options are given to users to discard their changes. For example, if a step-by-step has previously been published, it can’t be deleted.


### 2i workflows

There are two "happy path" 2i workflows that a step-by-step can follow

### A new step-by-step is created

|Action                       |Publication State|Workflow State      |
|-----------------------------|:---------------:|-------------------:|
|Create new step-by-step      |Draft            |N/A                 |				
|Makes changes to step-by-step|Draft            |N/A                 |				
|Submit for 2i                |Draft            |Submitted for 2i    |
|Claim Review                 |Draft            |In Review           |
|2i Approved                  |Draft            |2i Approved         |
|2i Requests change           |Draft            |N/A                 |
|Publish                      |Published        |N/A                 |
|Schedule                     |Draft            |Scheduled           |
|Unschedule                   |Draft            |2i Approved         |
|Delete                       |Draft            |N/A                 |

### A published step-by-step is updated

|Action                       |Publication State  |Workflow State      |
|-----------------------------|:-----------------:|-------------------:|
|Update published step-by-step|Published          |N/A                 |
|Make changes to step-by-step |Unpublished changes|N/A                 |
|Submit for 2i                |Unpublished changes|Submitted for 2i    |
|Claim Review                 |Unpublished changes|In Review           |
|2i Approved                  |Unpublished changes|2i Approved         |
|2i Requests changes          |Unpublished changes|N/A                 |
|Publish                      |Published          |N/A                 |
|Schedule                     |Unpublished changes|Scheduled           |
|Unschedule                   |Unpublished changes|2i Approved         |
|Discard Draft                |Published          |N/A                 |
|Unpublish                    |Draft              |N/A                 |


### Status assumptions

- Can only publish if workflow state is 2i Approved
- Can only schedule if workflow state is 2i Approved
- Can only Claim Review if workflow state is Submitted for 2i and the Claimer is not the same user as the one that submitted for 2i
- After 2i has been approved, the user can submit for 2i again
- If the 2i reviewer requests changes, the workflow state is reset and the 2i workflow starts again
- Can only delete a step-by-step if it’s never been published
- "live" will be renamed to "published" to be consistent with the other publishing apps.


## Decision

Create a new field in the database to store a value of `status` that allows values of:

- draft
- published
- scheduled
- submitted_for_2i
- in_review
- approved_2i


"draft" and "unpublished changes" mean the same thing in regards to their position in the publishing workflow, so if they are consolidated it won't be necessary to keep track of separate publication and workflow states. The presence of a `published_at` date can be used to determine if something has been previously published, as it is now.

That means the 2i workflow can be simplified.

### 2i workflow

|Action                                  |Starting Status |End Status          |
|----------------------------------------|:--------------:|-------------------:|
|Create new/update published step-by-step|N/A or published|draft               |
|Makes changes to step-by-step           |draft           |draft               |
|Submit for 2i                           |draft           |submitted_for_2i    |
|Claim Review                            |submitted_for_2i|in_review           |
|2i Approved                             |in_review       |approved_2i         |
|2i Requests changes                     |in_review       |draft               |
|Publish                                 |approved_2i     |published           |
|Schedule                                |approved_2i     |scheduled           |
|Unschedule                              |scheduled       |approved_2i         |


### Other actions

- Delete: Only if step-by-step is not scheduled or been previously published
- Discard Draft: Only if step-by-step is not scheduled and has been previously published
- Unpublish: Only if step-by-step is not scheduled and has been previously published


### Pros

- It will be easy to expand the allowed statuses to include factcheck statuses.
- It will be easier to query and filter step-by-steps by status.
- The status can be used by internal change notes to give a better description of what has changed.

### Cons

- Extra validation will be needed to ensure that a status can be set. E.g Cannot set to `in_review` if there is no `reviewer` recorded.
- Existing step-by-steps will need to be updated to store a status.

## Status

Accepted, 2019-09-03.
