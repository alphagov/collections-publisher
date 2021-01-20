# Temporary rake task whilst MVP publishing tool is under development:
# coronavirus_landing_page content items all have a sections_heading (eg Guidance and Support)
# and a title field eg "Coronavirus (COVID-19): guidance and support". Both of these fields
# are persisted in the collection publisher database, but they can still be updated in their relevant
# yaml eg: https://github.com/alphagov/govuk-coronavirus-content/blob/master/content/coronavirus_landing_page.yml
# If they get out of sync, this task can help.
require_relative "../../app/services/coronavirus_pages/model_builder"

namespace :coronavirus do
  desc "
  Resync the title field and the sections_heading fields with the values stored in the yaml file.
  Usage
  rake coronavirus:resync_titles[slug]
  "
  task :resync_titles, [:slug] => [:environment] do |_task, args|
    page = CoronavirusPage.find_by(slug: args.slug)
    builder ||= CoronavirusPages::ModelBuilder.new(args.slug)
    page.update!(
      title: builder.title,
      sections_title: builder.sections_heading,
    )
    puts "#{page.name} has been updated:"
    puts "title: #{page.title}"
    puts "sections_title: #{page.sections_title}"
  end

  desc "Sync timeline entries with entries in the yaml file"
  task sync_timeline_entries: :environment do
    CoronavirusPages::TimelineEntryBuilder.new.create_timeline_entries

    puts "Timeline Entries synced for coronavirus landing page..."
  end
end
