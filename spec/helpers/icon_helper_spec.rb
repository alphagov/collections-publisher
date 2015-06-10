require "rails_helper"

RSpec.describe IconHelper do
  describe '#icon' do
    it 'returns nothing for nil name' do
      expect(helper.icon(nil)).to eql(nil)
    end

    it 'returns a tag for an icon name' do
      expect(helper.icon(:some_name)).to eql '<i class="glyphicon glyphicon-some_name" data-toggle="tooltip" title="Some name"></i>'
    end

    it 'can use aliases' do
      expect(helper.icon(:curated)).to eql '<i class="glyphicon glyphicon-list-alt" data-toggle="tooltip" title="Curated"></i>'
    end
  end
end
