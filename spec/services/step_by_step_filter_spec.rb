require 'rails_helper'

RSpec.describe StepByStepFilter do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  let!(:draft_step_by_step) do
    create(
      :draft_step_by_step_page,
      title: "draft step by step",
      slug: "draft-step-by-step"
    )
  end

  let!(:published_step_by_step) do
    create(
      :published_step_by_step_page,
      title: "published step by step",
      slug: "published-step-by-step"
    )
  end

  let!(:scheduled_step_by_step) do
    create(
      :scheduled_step_by_step_page,
      title: "scheduled step by step",
      slug: "scheduled-step-by-step"
    )
  end

  context "filter by status" do
    it "returns a list of step by steps with a status of draft" do
      filter_params = {
        status: "draft"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq(draft_step_by_step.title)
    end

    it "returns a list of step by steps with a status of published" do
      filter_params = {
        status: "live"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq(published_step_by_step.title)
    end

    it "returns a list of step by steps with a status of scheduled" do
      filter_params = {
        status: "scheduled"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq(scheduled_step_by_step.title)
    end

    it "returns nothing if there are no matches" do
      filter_params = {
        status: "unpublished_changes"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(0)
    end
  end

  context "filter by title" do
    it "matches on the whole title" do
      filter_params = {
        title_or_url: "published step by step"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq(published_step_by_step.title)
    end

    context "partial titles" do
      it "matches on beginning of title" do
        filter_params = {
          title_or_url: "published"
        }
        results = described_class.new(filter_params).results

        expect(results.count).to eq(1)
        expect(results.first.title).to eq(published_step_by_step.title)
      end

      it "matches on end of title" do
        filter_params = {
          title_or_url: "by step"
        }
        results = described_class.new(filter_params).results

        expect(results.count).to eq(3)
      end
    end
  end

  context "filter by slug" do
    it "matches on slug" do
      filter_params = {
        title_or_url: "draft-step-by-step"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq(draft_step_by_step.title)
    end
  end

  it "filters by status and title" do
    filter_params = {
      status: "scheduled",
      title_or_url: "by step"
    }
    results = described_class.new(filter_params).results

    expect(results.count).to eq(1)
    expect(results.first.title).to eq(scheduled_step_by_step.title)
  end

  it "filters by status and slug" do
    filter_params = {
      status: "scheduled",
      title_or_url: "scheduled-step-by-step"
    }
    results = described_class.new(filter_params).results

    expect(results.count).to eq(1)
    expect(results.first.title).to eq(scheduled_step_by_step.title)
  end

  it "returns nothing if no step by steps with status and title exist" do
    filter_params = {
      status: "live",
      title_or_url: "scheduled-step-by-step"
    }
    results = described_class.new(filter_params).results

    expect(results.count).to eq(0)
  end
end
