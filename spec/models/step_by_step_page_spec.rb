require 'rails_helper'

RSpec.describe StepByStepPage do
  let(:step_by_step_page) { build(:step_by_step_page) }

  describe 'validations' do
    it 'is created with valid attributes' do
      expect(step_by_step_page).to be_valid
      expect(step_by_step_page.save).to eql true
      expect(step_by_step_page).to be_persisted
    end

    it 'requires a title' do
      step_by_step_page.title = ''

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors).to have_key(:title)
    end

    it 'requires a base path' do
      step_by_step_page.base_path = ''

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors).to have_key(:base_path)
    end

    it 'must have a valid base path' do
      [
        "not/a/valid/path",
        "not_a_valid_path",
        "not a valid path",
        "Not-a-Valid-Path",
        "-hyphen",
        "hyphen-"
      ].each do |base_path|
        step_by_step_page.base_path = base_path

        expect(step_by_step_page).not_to be_valid
        expect(step_by_step_page.errors).to have_key(:base_path)
      end
    end

    it 'must be a unique base path' do
      step_by_step_page.base_path = "new-step-by-step"
      step_by_step_page.save

      duplicate = create(:step_by_step_page)
      duplicate.base_path = step_by_step_page.base_path

      expect(duplicate.save).to eql false
      expect(duplicate.errors).to have_key(:base_path)
    end
  end
end
