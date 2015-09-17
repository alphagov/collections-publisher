
namespace :comparison do
  desc "report on differences in items tagged as reported by rummager and contentapi"
  task :run => :environment do
    require 'csv'
    require 'gds_api/content_api'
    Services.publishing_api(:content_api, GdsApi::ContentApi.new(Plek.new.find('content_api')))

    # Generates 2 CSV files reporting differences between the contentapi and
    # rummager views on the content items tagged to a given topic or
    # mainstream_browse_page
    #
    # rumager-missing.csv will contain a list of content items that are present
    # for a tag in contentapi, but not in rummager, along with the tag in question.
    #
    # contentapi-missing.csv will contain a list of content items that are
    # present for a tag in rummager, but not in contentapi, along with the tag in question.

    rummager_csv = CSV.open("rummager-missing.csv", "wb")
    rummager_csv << %w(tag_slug tag_type title format base_path)
    contentapi_csv = CSV.open("contentapi-missing.csv", "wb")
    contentapi_csv << %w(tag_slug tag_type title format base_path)

    Tag.only_children.includes(:parent).find_each do |tag|

      filter_key = tag.is_a?(Topic) ? "filter_specialist_sectors" : "filter_mainstream_browse_pages"
      rummager_data = Services.rummager.unified_search({
        :start => 0,
        :count => 10_000,
        filter_key => [tag.full_slug],
        :fields => %w(title link format),
      }).results

      begin
        contentapi_data = Services.publishing_api(:content_api).with_tag(tag.full_slug, tag.legacy_tag_type).results
      rescue GdsApi::HTTPNotFound
        contentapi_data = []
      end

      rummager_links = rummager_data.map(&:link)
      contentapi_links = contentapi_data.map {|r| URI.parse(r.web_url).path }

      contentapi_data.each do |c|
        path = URI.parse(c.web_url).path
        unless rummager_links.include?(path)
          rummager_csv << [tag.full_slug, tag.type, c.title, c.format, path]
        end
      end
      rummager_data.each do |r|
        unless contentapi_links.include?(r.link)
          contentapi_csv << [tag.full_slug, tag.type, r.title, r.format, r.link]
        end
      end

    end

    rummager_csv.close
    contentapi_csv.close
  end
end
