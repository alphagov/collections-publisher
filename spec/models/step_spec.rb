require 'rails_helper'

RSpec.describe Step do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    create(:link_check_report, batch_id: 1, step_id: step_item.id)
    create(:link_check_report, completed: Time.now, batch_id: 2, step_id: step_item.id)
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
    it 'should return the most recent batch_id' do
      expect(step_item.batch_link_report_id).to eql 2
    end

    it 'should get a mock back of a batch link report that has the id of 2' do
      batch_link_report = step_item.batch_link_report
      expect(batch_link_report.id).to eql 2
    end
  end
end
