require 'spec_helper'

describe MainstreamBrowsePagePresenter do

  let(:mainstream_browse_page) { double(:mainstream_browse_page,
    slug: 'citizenship',
    title: 'Citizenship',
    description: 'Living in the UK, passports',
    parent: nil,
    tag_type: 'section',
  ) }

  let(:presenter) { MainstreamBrowsePagePresenter.new(mainstream_browse_page) }

  describe '#render_for_panopticon' do
    it 'sets the tag_type to "section"' do
      expect(presenter.render_for_panopticon[:tag_type]).to eq('section')
    end
  end

end
