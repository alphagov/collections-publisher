require "rails_helper"

RSpec.describe "rake step_by_step:set_status", type: :task do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    Rake::Task["step_by_step:set_status"].reenable
  end

  it "sets the status to draft" do
    step_by_step = create(:draft_step_by_step_page)
    step_by_step.update_column(:status, "")

    Rake::Task["step_by_step:set_status"].invoke

    expect(step_by_step.reload.status).to be_draft
  end

  it "sets the status to published" do
    step_by_step = create(:published_step_by_step_page)
    step_by_step.update_column(:status, "")

    Rake::Task["step_by_step:set_status"].invoke

    expect(step_by_step.reload.status).to be_published
  end

  it "sets the status to scheduled" do
    step_by_step = create(:scheduled_step_by_step_page)
    step_by_step.update_column(:status, "")

    Rake::Task["step_by_step:set_status"].invoke

    expect(step_by_step.reload.status).to be_scheduled
  end

  it "sets the status to draft when there are unpublished changes" do
    step_by_step = create(:published_step_by_step_page, draft_updated_at: Time.zone.now)
    step_by_step.update_column(:status, "")

    Rake::Task["step_by_step:set_status"].invoke

    expect(step_by_step.reload.status).to be_draft
  end

  it "sets the status to draft if step by step has been unpublished" do
    step_by_step = create(:published_step_by_step_page)
    step_by_step.update_columns(
      status: "",
      published_at: nil,
      draft_updated_at: nil,
    )

    Rake::Task["step_by_step:set_status"].invoke

    expect(step_by_step.reload.status).to be_draft
  end
end
