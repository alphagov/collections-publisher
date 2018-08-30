require 'rails_helper'

RSpec.describe StepByStepPage do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  let!(:step_by_step_page) { build(:step_by_step_page, title: "Construct a giant castle made of armadillos") }

  describe '.by_title' do
    let!(:step_by_step_page_1) { create(:step_by_step_page, slug: "b", title: "Suffer the slings and arrows of outrageous fortune") }
    let!(:step_by_step_page_2) { create(:step_by_step_page, slug: "a", title: "Agonise over the next title you can think of") }

    it 'returns step by step pages in alphabetical order by title' do
      # binding.pry
      step_pages = StepByStepPage.by_title
      expect(step_pages.first.title).to eq "Agonise over the next title you can think of"
      expect(step_pages.last.title).to eq "Suffer the slings and arrows of outrageous fortune"
    end
  end

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

    it 'must not be present in publishing-api' do
      allow(Services.publishing_api).to receive(:lookup_content_id).and_return("A_CONTENT_ID")
      step_by_step_page.save

      expect(step_by_step_page.errors.full_messages).to eq(["Slug has already been taken."])
    end
  end

  describe 'steps association' do
    let(:step_by_step_with_step) { create(:step_by_step_page_with_steps) }

    it 'is created with a step' do
      expect(step_by_step_with_step.steps.length).to eql(2)
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

  describe '#links_last_checked_date' do
    it 'gets the latest date that links were checked for any step' do
      step_by_step_with_step = create(:step_by_step_page)

      step1 = create(:step, step_by_step_page: step_by_step_with_step)
      step2 = create(:step, step_by_step_page: step_by_step_with_step)

      create(:link_report, batch_id: 1, step_id: step1.id, created_at: "2018-08-07 10:31:38")
      create(:link_report, batch_id: 2, step_id: step2.id, created_at: "2018-08-07 10:30:38")

      expect(step_by_step_with_step.links_last_checked_date).to eq("Tuesday, 07 August 2018 at 10:31 AM")
    end

    it 'does not fail if there are no link reports' do
      step_by_step_with_step = create(:step_by_step_page)

      expect(step_by_step_with_step.links_last_checked_date).to be nil
    end
  end

  describe 'links_checked?' do
    it 'returns true if links have been checked' do
      step_by_step_with_step = create(:step_by_step_page)
      step = create(:step, step_by_step_page: step_by_step_with_step)
      create(:link_report, batch_id: 1, step_id: step.id)

      expect(step_by_step_with_step.links_checked?).to be true
    end

    it 'returns false if links have not been checked' do
      step_by_step_with_step = create(:step_by_step_page)

      expect(step_by_step_with_step.links_checked?).to be false
    end
  end

  describe 'publishing' do
    let(:step_by_step_page) { create(:step_by_step_page) }

    it 'should update draft date' do
      nowish = Time.zone.now
      Timecop.freeze do
        step_by_step_page.mark_draft_updated

        expect(step_by_step_page.draft_updated_at).to be_within(1.second).of nowish
        expect(step_by_step_page.has_draft?).to be true
        expect(step_by_step_page.status[:name]).to eq('draft')
      end
    end

    it 'should reset draft date' do
      step_by_step_page.mark_draft_deleted

      expect(step_by_step_page.draft_updated_at).to be nil
      expect(step_by_step_page.has_draft?).to be false
    end

    it 'should update published date' do
      nowish = Time.zone.now
      Timecop.freeze do
        step_by_step_page.mark_as_published

        expect(step_by_step_page.published_at).to be_within(1.second).of nowish
        expect(step_by_step_page.published_at).to eq(step_by_step_page.draft_updated_at)
        expect(step_by_step_page.has_been_published?).to be true
        expect(step_by_step_page.has_draft?).to be false
        expect(step_by_step_page.status[:name]).to eq('live')
      end
    end

    it 'should reset published date' do
      step_by_step_page.mark_as_unpublished

      expect(step_by_step_page.published_at).to be nil
      expect(step_by_step_page.has_been_published?).to be false
      expect(step_by_step_page.draft_updated_at).to be nil
      expect(step_by_step_page.has_draft?).to be false
    end

    it 'should have a deterministically generated hex string' do
      step_by_step_with_custom_id = create(:step_by_step_page, content_id: 123, slug: 'slug')
      expect(step_by_step_with_custom_id.auth_bypass_id).to eq("61363635-6134-4539-b230-343232663964")
    end

    it 'should have a status of unpublished if published and then changes are made' do
      step_by_step_page.mark_as_published

      Timecop.freeze(Date.today + 1) do
        step_by_step_page.mark_draft_updated
        expect(step_by_step_page.status[:name]).to eq('unpublished_changes')
      end
    end
  end
end
