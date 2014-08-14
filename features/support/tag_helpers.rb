require 'gds_api/test_helpers/content_api'

module TagHelpers
  include GdsApi::TestHelpers::ContentApi

  def stub_live_specialist_sectors(parent: nil, sectors:, content: {})
    if parent
      sectors.map! { |sector| sector.merge(parent: parent) }
      sectors.unshift(parent)
    end

    content_api_has_sorted_tags('specialist_sector', 'alphabetical', sectors)

    content.each do |tag_slug, artefact_slugs|
      content_api_has_artefacts_with_a_tag('specialist_sector', tag_slug, artefact_slugs)
    end
  end
end

World(TagHelpers)
