require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require "gds_api/test_helpers/publishing_api"

RSpec.describe StepByStepPagesController do
  include GdsApi::TestHelpers::PublishingApiV2
  include GdsApi::TestHelpers::PublishingApi

  let(:step_by_step_page) { create(:step_by_step_page_with_steps) }
  let(:stub_user) { create(:user, name: "Name Surname", permissions: ["signin", "GDS Editor"]) }

  before do
    allow(Services.publishing_api).to receive(:lookup_content_id).and_return(nil)

    allow(Services.publishing_api).to receive(:get_content)
      .with(step_by_step_page.content_id)
      .and_return(content_item(step_by_step_page))
  end

  describe "GET Step by step index page" do
    it "can only be accessed by users with GDS editor permissions" do
      get :index

      expect(response.status).to eq(200)
    end

    it "cannot be accessed by users without GDS editor permissions" do
      stub_user.permissions = %w(signin)
      get :index

      expect(response.status).to eq(403)
    end
  end

  describe "GET Step by step schedule page" do
    it "can only be accessed by users with Scheduling permissions" do
      stub_user.permissions << "Scheduling"
      get :schedule, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(200)
    end

    it "cannot be accessed by users without Scheduling permissions" do
      get :schedule, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(403)
    end
  end

  describe "#publish" do
    context 'major updates' do
      it "generates an internal change note with change note text" do
        stub_publishing_api

        change_note_text = "Testing major change note"
        post :publish, params: { step_by_step_page_id: step_by_step_page.id, update_type: "major", change_note: change_note_text }

        expected_description = "Major update published by Name Surname with note: #{change_note_text}"
        expect(step_by_step_page.internal_change_notes.first.description).to eq expected_description
      end
    end

    context 'minor updates' do
      it "generates an internal change note with change note text" do
        stub_publishing_api

        change_note_text = "Corrected a typo"
        post :publish, params: { step_by_step_page_id: step_by_step_page.id, update_type: "minor", change_note: change_note_text }

        expected_description = "Minor update published by Name Surname with note: #{change_note_text}"
        expect(step_by_step_page.internal_change_notes.first.description).to eq expected_description
      end

      it "generates an internal change note without change note text" do
        stub_publishing_api
        post :publish, params: { step_by_step_page_id: step_by_step_page.id, update_type: "minor", change_note: "" }

        expected_description = "Minor update published by Name Surname"
        expect(step_by_step_page.internal_change_notes.first.description).to eq expected_description
      end
    end

    it "sets the edition number of the change notes" do
      create(:internal_change_note, step_by_step_page_id: step_by_step_page.id)

      stub_publishing_api
      post :publish, params: { step_by_step_page_id: step_by_step_page.id, update_type: "minor", change_note: "" }

      expect(step_by_step_page.internal_change_notes.first.edition_number).to eq(3)
    end
  end

  describe "#unschedule" do
    before :each do
      stub_user.permissions << "Scheduling"

      allow(Services.publishing_api).to receive(:get_content)
        .and_return(content_item(step_by_step_page))
    end

    it "clears Scheduled status and sets it back to Draft" do
      step_by_step_page = create(:scheduled_step_by_step_page, slug: 'how-to-be-fantastic')

      unschedule_publishing(step_by_step_page)

      expect(step_by_step_page.scheduled_at).to eq nil
      expect(step_by_step_page.scheduled_for_publishing?).to be false
      expect(step_by_step_page.status[:name]).to eq 'draft'
    end

    it "clears Scheduled status and sets it back to Unpublished changes" do
      step_by_step_page = create(:published_step_by_step_page, draft_updated_at: Time.zone.now, scheduled_at: 2.hours.from_now, slug: 'how-to-be-fantastic2')

      unschedule_publishing(step_by_step_page)

      expect(step_by_step_page.scheduled_at).to eq nil
      expect(step_by_step_page.scheduled_for_publishing?).to be false
      expect(step_by_step_page.status[:name]).to eq 'unpublished_changes'
    end

    it "creates and internal change note" do
      step_by_step_page = create(:scheduled_step_by_step_page, slug: 'how-to-be-fantastic')

      unschedule_publishing(step_by_step_page)

      expected_description = "Publishing was unscheduled by Name Surname."
      expect(step_by_step_page.internal_change_notes.first.description).to eq expected_description
    end
  end

  describe "#revert" do
    it "reverts the step by step page to the published version" do
      allow(Services.publishing_api).to receive(:discard_draft)

      allow(Services.publishing_api).to receive(:get_content)
        .with(step_by_step_page.content_id, version: 2)
        .and_return(content_item(step_by_step_page))

      allow_any_instance_of(StepByStepPageReverter).to receive(:repopulate_from_publishing_api)

      expect(Services.publishing_api).to receive(:get_content).with(step_by_step_page.content_id, version: 2)

      post :revert, params: { step_by_step_page_id: step_by_step_page.id }
    end
  end

  def content_item(step_by_step_page)
    {
      content_id: step_by_step_page.content_id,
      base_path: base_path(step_by_step_page.slug),
      title: step_by_step_page.title,
      description: step_by_step_page.description,
      schema_name: "step_by_step_nav",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      state_history: {
        "3" => "draft",
        "2" => "published",
        "1" => "superseded",
      }
    }
  end

  def base_path(slug)
    "/#{slug}"
  end

  def stub_publishing_api
    allow(Services.publishing_api).to receive(:lookup_content_ids).with(
      base_paths: [base_path(step_by_step_page.slug)],
      with_drafts: true
    ).and_return({})

    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  def unschedule_publishing(step_by_step_page)
    stub_publishing_api_destroy_intent(base_path(step_by_step_page.slug))
    post :unschedule, params: { step_by_step_page_id: step_by_step_page.id }
    step_by_step_page.reload
  end
end
