module CoronavirusHelpers
  def stub_coronavirus_landing_page_content(coronavirus_page)
    raw_content = File.read(Rails.root.join("spec/fixtures/coronavirus_landing_page.yml"))
    stub_request(:get, /#{coronavirus_page.raw_content_url}\?cache-bust=\d+/)
      .to_return(status: 200, body: raw_content)
  end
end
