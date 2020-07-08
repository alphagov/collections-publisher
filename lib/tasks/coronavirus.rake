## This rake task deletes all CoronavirusPage from the collections publisher database
## Once it's been run, visiting https://collections-publisher.publishing.service.gov.uk/coronavirus will
## trigger the latest data to be pulled from github, and then this task should be deleted.

namespace :coronavirus do
  desc "
  Delete all coronavirus records.
  Usage
  rake coronavirus:resync_database[dry_run_false]
  "
  task :resync_database, [:dry_run] => [:environment] do |_task, args|
    count = CoronavirusPage.count
    slugs = CoronavirusPage.all.pluck(:slug)

    if args.dry_run == "dry_run_false"
      puts "Deleting #{count} coronavirus pages from the database: #{slugs}"
      CoronavirusPage.destroy_all
      CoronavirusPage.any? ? "Something went wrong, #{slugs} were not deleted." : "Done"
    else
      puts "This task is in dry run mode. It would have removed #{count} coronavirus pages from the database: #{slugs}"
    end
  end
end
