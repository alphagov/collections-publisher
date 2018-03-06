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

    it 'requires a slug' do
      step_by_step_page.slug = ''

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors).to have_key(:slug)
    end

    it 'requires an introduction' do
      step_by_step_page.introduction = ''

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors).to have_key(:introduction)
    end

    it 'requires a meta description' do
      step_by_step_page.description = ''

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors).to have_key(:description)
    end

    it 'must have a valid slug' do
      [
        "not/a/valid/path",
        "not_a_valid_path",
        "not a valid path",
        "Not-a-Valid-Path",
        "-hyphen",
        "hyphen-"
      ].each do |slug|
        step_by_step_page.slug = slug

        expect(step_by_step_page).not_to be_valid
        expect(step_by_step_page.errors).to have_key(:slug)
      end
    end

    it 'must be a unique slug' do
      step_by_step_page.slug = "new-step-by-step"
      step_by_step_page.save

      duplicate = build(:step_by_step_page)
      duplicate.slug = step_by_step_page.slug

      expect(duplicate.save).to eql false
      expect(duplicate.errors).to have_key(:slug)
    end

    it 'must be a unique content_id' do
      duplicate = create(:step_by_step_page)
      step_by_step_page.content_id = duplicate.content_id

      expect {
        step_by_step_page.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'steps association' do
    let(:step_by_step_with_step) { create(:step_by_step_page_with_steps) }

    it 'is created with a step' do
      expect(step_by_step_with_step.steps.length).to eql(1)
    end

    it 'deletes steps when the StepByStepPage is deleted' do
      step_by_step_with_step.destroy

      expect { step_by_step_with_step.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(step_by_step_with_step.steps.length).to eql(0)
    end
  end

  describe 'when it has many steps' do
    let(:step_by_step_with_step) { create(:step_by_step_page) }

    it 'should list steps in ascending order' do
      step1 = create(:step, step_by_step_page: step_by_step_with_step)
      step2 = create(:step, step_by_step_page: step_by_step_with_step)
      step3 = create(:step, step_by_step_page: step_by_step_with_step)

      expect(step_by_step_with_step.reload.steps).to eq([step1, step2, step3])
    end
  end

  it 'must be a unique content_id' do
    duplicate = create(:step_by_step_page)
    step_by_step_page.content_id = duplicate.content_id

    expect {
      step_by_step_page.save(validate: false)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
