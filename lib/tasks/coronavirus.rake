namespace :coronavirus do
  desc "Sync header section with header section in the yaml file"
  task sync_header_section: :environment do
    Coronavirus::Pages::HeaderSectionBuilder.new.create_header

    puts "Header section synced for coronavirus landing page."
  end
end
