require 'rails_helper'

RSpec.describe Step do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  let(:step_item) { build(:step) }

  describe 'validations' do
    it 'should belong to a step_by_step_page' do
      should validate_presence_of(:step_by_step_page)
    end

    it 'fails if step_by_step_page does not exist' do
      step_item.step_by_step_page = nil

      expect(step_item).not_to be_valid
    end

    it 'is created with valid attributes' do
      expect(step_item).to be_valid
      expect(step_item.save).to eql true
      expect(step_item).to be_persisted
    end

    it 'requires a title' do
      step_item.title = ''

      expect(step_item).not_to be_valid
      expect(step_item.errors).to have_key(:title)
    end

    it 'requires logic' do
      step_item.logic = ''

      expect(step_item).not_to be_valid
      expect(step_item.errors).to have_key(:logic)
    end
  end

  describe 'link reports' do
    it 'should return nothing if there are no link reports yet' do
      expect(step_item.broken_links).to be_nil
    end
    it 'should contain one item if there are link reports and at least one is broken' do
      create(:link_report, batch_id: 1, step_id: step_item.id)
      create(:link_report, completed: Time.now, batch_id: 2, step_id: step_item.id)
      expect(step_item.broken_links.length).to eql 1
      broken_link_report = step_item.broken_links.first
      expect(broken_link_report.fetch('uri')).to eq "https://www.gov.uk/404"
      expect(broken_link_report.fetch('problem_summary')).to eq "404 error (page not found)"
    end
  end
end
