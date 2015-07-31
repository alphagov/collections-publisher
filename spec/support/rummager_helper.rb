module RummagerHelper
  SEARCH_ENDPOINT = Plek.find('rummager') + '/unified_search.json'

  def stub_rummager_linked_content_call
    stub_any_call_to_rummager_with_documents([])
  end

  def stub_any_call_to_rummager_with_documents(rummager_documents)
    stub_request(:get, %r[\A#{Regexp.escape(SEARCH_ENDPOINT)}.])
      .to_return(body: JSON.dump(results: rummager_documents))
  end
end

RSpec.configure do |config|
  config.include RummagerHelper
end
