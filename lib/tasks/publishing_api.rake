namespace :publishing_api do
  desc "Send all tags to the publishing-api, skipping any marked as dirty"
  task :send_all_tags => :environment do
    TagRepublisher.new.republish_tags(Tag.all)
    RedirectPublisher.new.republish_redirects
  end

  desc "Send all published tags to the publishing-api, skipping any marked as dirty"
  task :send_published_tags => :environment do
    TagRepublisher.new.republish_tags(Tag.published)
  end

  desc "Populates parent taxons with the links parent"
  task populate_parent_taxons: :environment do
    Taxonomy::TaxonFetcher.new.taxons.each do |taxon|
      Rails.logger.info "Populating taxon parent for #{taxon['title']}"
      Taxonomy::PopulateParentTaxons.run(content_id: taxon['content_id'])
    end
  end
end
