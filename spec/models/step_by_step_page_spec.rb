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

    it 'must have a scheduled_at value that is nil or in the future' do
      valid_values = [
        nil,
        'foo', # automatically converted to nil
        1.day.from_now,
        Time.zone.now + 1.minute,
      ]
      invalid_values = [
        Time.zone.now,
        1.day.ago,
      ]

      valid_values.each do |good_val|
        step_by_step_page.scheduled_at = good_val
        expect(step_by_step_page).to be_valid
      end
      invalid_values.each do |bad_val|
        step_by_step_page.scheduled_at = bad_val
        expect(step_by_step_page).not_to be_valid
        expect(step_by_step_page.errors).to have_key(:scheduled_at)
      end
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

    it 'does not allow the reviewer to be the same as the review requester' do
      user_uid = SecureRandom.uuid
      step_by_step_page.review_requester_id = user_uid
      step_by_step_page.reviewer_id = user_uid

      step_by_step_page.save

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors).to have_key(:reviewer_id)
    end

    describe '#status' do
      it 'requires a status' do
        step_by_step_page.status = ''

        expect(step_by_step_page).not_to be_valid
        expect(step_by_step_page.errors).to have_key(:status)
      end

      it 'must have a valid status' do
        step_by_step_page.status = 'invalid'

        expect(step_by_step_page).not_to be_valid
        expect(step_by_step_page.errors).to have_key(:status)
      end
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

      expect(step_by_step_with_step.links_last_checked_date).to eq(Time.zone.local(2018, 8, 7, 10, 31, 38))
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
        expect(step_by_step_page.status).to be_draft
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
        expect(step_by_step_page.status).to be_published
      end
    end

    it 'should reset scheduled date' do
      step_by_step_page.scheduled_at = Date.today

      step_by_step_page.mark_as_published

      expect(step_by_step_page.scheduled_at).to be nil
      expect(step_by_step_page.scheduled_for_publishing?).to be false
    end

    it 'should unassign the user' do
      step_by_step_page.assigned_to = "Test User"
      step_by_step_page.mark_as_published

      expect(step_by_step_page.assigned_to).to be nil
    end

    it 'should unassign the review requester' do
      stub_user = create(:user)
      step_by_step_page.review_requester_id = stub_user.uid
      step_by_step_page.mark_as_published

      expect(step_by_step_page.review_requester_id).to be nil
    end

    it 'should unassign the reviewer' do
      stub_user = create(:user)
      step_by_step_page.review_requester_id = stub_user.uid
      step_by_step_page.reviewer_id = stub_user.uid
      step_by_step_page.mark_as_published

      expect(step_by_step_page.reviewer_id).to be nil
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

    it 'should have a status of draft if published and then changes are made' do
      step_by_step_page.mark_as_published

      Timecop.freeze(Date.today + 1) do
        step_by_step_page.mark_draft_updated
        expect(step_by_step_page.status).to be_draft
      end
    end
  end

  describe 'scheduled publishing' do
    let(:step_by_step_page) { create(:step_by_step_page) }

    it 'is scheduled for publishing when it has a draft and has a scheduled_at date' do
      step_by_step_page.mark_draft_updated
      step_by_step_page.scheduled_at = Date.tomorrow
      step_by_step_page.mark_as_scheduled

      expect(step_by_step_page.scheduled_for_publishing?).to be true
      expect(step_by_step_page.status).to be_scheduled
    end

    it 'is not scheduled for publishing if a draft has not been saved' do
      step_by_step_page.scheduled_at = Date.tomorrow
      expect(step_by_step_page.scheduled_for_publishing?).to be false
    end

    it 'is not scheduled for publishing if scheduled_at is not present' do
      step_by_step_page.mark_draft_updated
      expect(step_by_step_page.scheduled_for_publishing?).to be false
    end
  end

  describe '#can_be_published?' do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps) }

    it 'can be published if it has a draft, is not scheduled for publishing and all steps have content' do
      step_by_step_page.mark_draft_updated

      expect(step_by_step_page.can_be_published?).to be true
    end

    it 'cannot be published if it does not have a draft' do
      expect(step_by_step_page.can_be_published?).to be false
    end

    it 'cannot be published if it is scheduled for publishing' do
      step_by_step_page.mark_draft_updated
      step_by_step_page.scheduled_at = Date.tomorrow
      step_by_step_page.mark_as_scheduled

      expect(step_by_step_page.can_be_published?).to be false
    end

    it 'cannot be published if there are no steps' do
      step_by_step_page = create(:step_by_step_page, slug: "no-steps")
      step_by_step_page.mark_draft_updated

      expect(step_by_step_page.can_be_published?).to be false
    end

    it 'cannot be published if all steps do not have content' do
      create(:step, step_by_step_page: step_by_step_page, contents: "")
      step_by_step_page.mark_draft_updated

      expect(step_by_step_page.can_be_published?).to be false
    end
  end

  describe '#can_be_unpublished?' do
    let(:step_by_step_page) { create(:step_by_step_page) }

    it 'can be unpublished if it has been published and it is not scheduled for publishing' do
      step_by_step_page.mark_as_published

      expect(step_by_step_page.can_be_unpublished?).to be true
    end

    it 'cannot be unpublished if it is scheduled for publishing' do
      step_by_step_page.mark_draft_updated
      step_by_step_page.scheduled_at = Date.tomorrow

      expect(step_by_step_page.can_be_unpublished?).to be false
    end

    it 'cannot be unpublished if it has not been published' do
      expect(step_by_step_page.can_be_unpublished?).to be false
    end
  end

  describe '#can_discard_changes?' do
    let(:step_by_step_page) { create(:step_by_step_page) }

    it 'can discard changes if it has unpublished changes and it is not scheduled for publishing' do
      step_by_step_page.published_at = Time.zone.now - 1.hour
      step_by_step_page.mark_draft_updated

      expect(step_by_step_page.can_discard_changes?).to be true
    end

    it 'cannot discard changes if it does not have unpublished changes' do
      expect(step_by_step_page.can_discard_changes?).to be false
    end

    it 'cannot discard changes if it is scheduled for publishing' do
      step_by_step_page.mark_draft_updated
      step_by_step_page.scheduled_at = Date.tomorrow

      expect(step_by_step_page.can_discard_changes?).to be false
    end
  end

  describe '#can_be_deleted?' do
    let(:step_by_step_page) { create(:step_by_step_page) }

    it 'can be deleted if it has not been published and it is not scheduled for publishing' do
      expect(step_by_step_page.can_be_deleted?).to be true
    end

    it 'cannot be deleted if it is scheduled for publishing' do
      step_by_step_page.mark_draft_updated
      step_by_step_page.scheduled_at = Date.tomorrow
      step_by_step_page.mark_as_scheduled

      expect(step_by_step_page.can_be_deleted?).to be false
    end

    it 'cannot be deleted if it has been published' do
      step_by_step_page.mark_as_published

      expect(step_by_step_page.can_be_deleted?).to be false
    end
  end

  describe '#can_be_edited?' do
    let(:step_by_step_page) { create(:step_by_step_page) }

    it 'can be edited if it is not scheduled for publishing' do
      expect(step_by_step_page.can_be_edited?).to be true
    end

    it 'cannot be edited if it is scheduled for publishing' do
      step_by_step_page.mark_draft_updated
      step_by_step_page.scheduled_at = Date.tomorrow
      step_by_step_page.mark_as_scheduled

      expect(step_by_step_page.can_be_edited?).to be false
    end
  end

  describe '.internal_change_notes' do
    context 'when there are changenotes' do
      it 'returns an array of changenotes in chronological order' do
        step_by_step_page = create(:step_by_step_page)
        id = step_by_step_page.id
        create(:internal_change_note, created_at: "2018-08-07 10:35:38", description: "First note", step_by_step_page_id: id)
        create(:internal_change_note, created_at: "2018-08-07 11:35:38", description: "Second note", step_by_step_page_id: id)
        expect(step_by_step_page.internal_change_notes.map(&:description)).to eql ["Second note", "First note"]
      end
    end
    context 'when there are no changenotes' do
      it 'returns an empty array' do
        step_by_step_page = create(:step_by_step_page)
        expect(step_by_step_page.internal_change_notes).to be_empty
      end
    end
  end

  describe '.discard_notes' do
    before(:each) do
      @step_by_step_page = create(:step_by_step_page)
      create(:internal_change_note, edition_number: 1, step_by_step_page_id: @step_by_step_page.id)
      create(:internal_change_note, step_by_step_page_id: @step_by_step_page.id)
    end
    context 'when there are existing change notes with a version and new change notes without a version' do
      before(:each) do
        @step_by_step_page.discard_notes
        @step_by_step_page.reload
      end
      it 'should only delete the change notes without an edition' do
        expect(@step_by_step_page.internal_change_notes.count).to eq 1
        expect(@step_by_step_page.internal_change_notes.first[:edition_number]).to eql 1
      end
    end
  end

  describe 'secondary content association' do
    let(:step_by_step) { create(:step_by_step_page_with_secondary_content) }

    it 'is created with a secondary content link' do
      expect(step_by_step.secondary_content_links.length).to eql(1)
    end

    it 'deletes secondary content when the StepByStepPage is deleted' do
      step_by_step.destroy

      expect { step_by_step.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(step_by_step.secondary_content_links.length).to eql(0)
    end
  end
end
