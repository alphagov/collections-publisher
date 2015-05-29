require 'rails_helper'

RSpec.describe TopicPresenter do
  describe "rendering for publishing-api" do
    let(:parent) { create(:topic, :slug => 'oil-and-gas') }
    let(:topic) {
      create(:topic, {
        :parent => parent,
        :slug => 'offshore',
        :title => 'Offshore',
        :description => 'Oil rigs, pipelines etc.',
      })
    }
    let(:presenter) { TopicPresenter.new(topic) }
    let(:presented_data) { presenter.render_for_publishing_api }

    it "returns the base_path for the browse page" do
      expect(presenter.base_path).to eq("/oil-and-gas/offshore")
    end

    it "includes the base fields" do
      expect(presented_data).to include({
        :content_id => topic.content_id,
        :format => 'topic',
        :title => 'Offshore',
        :description => 'Oil rigs, pipelines etc.',
        :locale => 'en',
        :need_ids => [],
        :publishing_app => 'collections-publisher',
        :rendering_app => 'collections',
        :redirects => [],
        :update_type => "major",
      })
    end

    it "is valid against the schema", :schema_test => true do
      expect(presented_data).to be_valid_against_schema('topic')
    end

    it "is valid against the schema for a top-level topic", :schema_test => true do
      data = TopicPresenter.new(parent).render_for_publishing_api
      expect(data).to be_valid_against_schema('topic')
    end

    it "sets public_updated_at based on the browse page update time" do
      Timecop.travel 3.hours.ago do
        topic.save!
      end

      expect(presented_data[:public_updated_at]).to eq(topic.updated_at.iso8601)
    end

    describe "routing" do
      it "includes routes for latest, and email_signups in addition to base route" do
        expect(presented_data[:routes]).to eq([
          {:path => "/oil-and-gas/offshore", :type => "exact"},
          {:path => "/oil-and-gas/offshore/latest", :type => "exact"},
          {:path => "/oil-and-gas/offshore/email-signup", :type => "exact"},
          {:path => "/oil-and-gas/offshore/email-signups", :type => "exact"},
        ])
      end

      it "only includes the base route for a top-level topic" do
        data = TopicPresenter.new(parent).render_for_publishing_api

        expect(data[:routes]).to eq([
          {:path => "/oil-and-gas", :type => "exact"},
        ])
      end
    end

    it "has no links" do
      expect(presented_data[:links]).to eq({})
    end
  end
end
