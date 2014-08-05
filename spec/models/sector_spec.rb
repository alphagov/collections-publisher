require 'spec_helper'
require 'gds_api/test_helpers/content_api'

describe Sector do
  include GdsApi::TestHelpers::ContentApi

  before do
    content_api_has_tags('specialist_sector', [
      'parent-tag',
      {
        title: 'Example sector 1',
        slug: 'example-sector-1',
        parent: 'parent-tag'
      },
      {
        title: 'Example sector 2',
        slug: 'example-sector-2',
        parent: 'parent-tag'
      }
    ])
  end

  describe '.find(slug)' do
    it "returns a sector with the same tag if found" do
      sector = Sector.find('example-sector-1')
      expect(sector).to be_a(Sector)
      expect(sector.title).to eq('Example sector 1')
    end

    it "returns nil if not found" do
      sector = Sector.find('absent-sector')
      expect(sector).to be_nil
    end
  end

  describe '.all_children' do
    it "returns all children" do
      sectors = Sector.all_children

      sectors.each do |sector|
        expect(sector).to be_a(Sector)
        expect(sector.parent).not_to be_nil
      end

      expect(sectors.map(&:title).to_set).to eq(['Example sector 1', 'Example sector 2'].to_set)
    end
  end

  describe '#lists' do
    it "returns all lists for that sector, if any" do
      list = FactoryGirl.create(:list, sector_id: 'example-sector-1')

      sector1 = Sector.find('example-sector-1')
      expect(sector1.lists).to eq([list])

      sector2 = Sector.find('example-sector-2')
      expect(sector2.lists).to eq([])
    end
  end

  describe '#all_content_api_urls' do
    it "returns the API URLs for all content tagged to the sector, if any" do
      content_api_has_artefacts_with_a_tag('specialist_sector', 'example-sector-1', [
        'example-content-1',
        'example-content-2'
      ])
      content_api_has_artefacts_with_a_tag('specialist_sector', 'example-sector-2', [])

      sector1 = Sector.find('example-sector-1')
      expect(sector1.all_content_api_urls).to eq([
        "#{Plek.new.find('contentapi')}/example-content-1.json",
        "#{Plek.new.find('contentapi')}/example-content-2.json"
      ])

      sector2 = Sector.find('example-sector-2')
      expect(sector2.all_content_api_urls).to eq([])

    end
  end

  it "defers to the slug when parameterized" do
    sector1 = Sector.find('example-sector-1')

    expect(sector1.to_param).to eq('example-sector-1')
  end
end
