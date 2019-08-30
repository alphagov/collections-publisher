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
        status: "published"
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

    it "matches on base_path" do
      filter_params = {
        title_or_url: "/draft-step-by-step"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq(draft_step_by_step.title)
    end

    it "matches on full url" do
      filter_params = {
        title_or_url: "http://wwww.gov.uk/draft-step-by-step"
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
      status: "published",
      title_or_url: "scheduled-step-by-step"
    }
    results = described_class.new(filter_params).results

    expect(results.count).to eq(0)
  end

  context "no filter params" do
    it "returns all step by steps if none of the filters params have a value" do
      filter_params = {
        status: "",
        title_or_url: ""
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(3)
    end

    it "returns all step by steps if there aren't any filter params" do
      results = described_class.new.results

      expect(results.count).to eq(3)
    end
  end

  context "ordering results" do
    let!(:new_step_by_step) do
      create(
        :scheduled_step_by_step_page,
        title: "new scheduled step by step",
        slug: "new-scheduled-step-by-step",
        scheduled_at: 4.hours.from_now
      )
    end

    it "returns results ordered by title by default" do
      filter_params = {
        status: "scheduled",
        title_or_url: "scheduled"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(2)
      expect(results.first.title).to eq(new_step_by_step.title)
      expect(results.last.title).to eq(scheduled_step_by_step.title)
    end

    it "orders results by any step by step attribute" do
      filter_params = {
        status: "scheduled",
        title_or_url: "scheduled",
        order_by: "scheduled_at"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(2)
      expect(results.first.title).to eq(scheduled_step_by_step.title)
      expect(results.last.title).to eq(new_step_by_step.title)
    end

    it "returns all results if order by attribute is invalid" do
      filter_params = {
        status: "scheduled",
        title_or_url: "scheduled",
        order_by: "foo"
      }
      results = described_class.new(filter_params).results

      expect(results.count).to eq(2)
    end
  end
end
