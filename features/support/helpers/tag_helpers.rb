require 'gds_api/test_helpers/content_api'

module TagHelpers
  include GdsApi::TestHelpers::ContentApi

  def stub_live_specialist_sectors(*args)
    stub_specialist_sectors(*args)
  end

  def stub_draft_specialist_sectors(parent: nil, sectors:, content: {})
    stub_specialist_sectors(draft: true, parent: parent, sectors: sectors, content: content)
  end

  def stub_specialist_sectors(draft: false, parent: nil, sectors:, content: {})
    if parent
      sectors.map! { |sector| sector.merge(parent: parent) }
    end

    content_api_has_draft_and_live_tags(type: 'specialist_sector', sort_order: 'alphabetical', live: [parent], draft: [])

    if draft
      content_api_has_draft_and_live_tags(type: 'specialist_sector', sort_order: 'alphabetical', draft: sectors, live: [])

      content.each do |tag_slug, artefact_slugs|
        content_api_has_artefacts_with_a_draft_tag('specialist_sector', tag_slug, artefact_slugs)
      end
    else
      content_api_has_draft_and_live_tags(type: 'specialist_sector', sort_order: 'alphabetical', live: sectors, draft: [])

      content.each do |tag_slug, artefact_slugs|
        content_api_has_artefacts_with_a_tag('specialist_sector', tag_slug, artefact_slugs)
      end
    end
  end
end

World(TagHelpers)
