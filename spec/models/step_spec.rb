require 'rails_helper'
require 'gds_api/test_helpers/link_checker_api'

RSpec.describe Step do
  include GdsApi::TestHelpers::LinkCheckerApi
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
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
  describe 'broken_links' do
    it 'should return nothing if there are no link reports yet' do
      expect(step_item.broken_links).to be_nil
    end

    it 'should return an empty array if there are link reports, but all the links work' do
      create(:link_report, batch_id: 2, step_id: step_item.id)
      link_checker_api_get_batch(
        id: 2,
        links: [
          {
            "uri": "https://www.gov.uk/",
            "status": "ok",
            "checked": "2017-04-12T18:47:16Z",
            "errors": [],
            "warnings": [],
            "problem_summary": "null",
            "suggested_fix": "null"
          }
        ]
      )
      expect(step_item.broken_links).to eql []
    end

    it 'should return a batch report if there is one with a matching id and it contains a broken link' do
      link_checker_api_get_batch(
        id: 2,
        links: [
          {
            "uri": "https://www.gov.uk/",
            "status": "ok",
            "checked": "2017-04-12T18:47:16Z",
            "errors": [],
            "warnings": [],
            "problem_summary": "null",
            "suggested_fix": "null"
          },
          {
            "uri": "https://www.gov.uk/404",
            "status": "broken",
            "checked": "2017-04-12T16:30:39Z",
            "errors": [
              "Received 404 response from the server."
            ],
            "warnings": [],
            "problem_summary": "404 error (page not found)",
            "suggested_fix": ""
          }
        ]
        )
      create(:link_report, batch_id: 2, step_id: step_item.id)
      expect(step_item.broken_links).to_not be_empty
    end

    it 'should contain one item if there are link reports and at least one is broken' do
      link_checker_api_get_batch(
        id: 2,
        links: [
          {
            "uri": "https://www.gov.uk/",
            "status": "ok",
            "checked": "2017-04-12T18:47:16Z",
            "errors": [],
            "warnings": [],
            "problem_summary": "null",
            "suggested_fix": "null"
          },
          {
            "uri": "https://www.gov.uk/404",
            "status": "broken",
            "checked": "2017-04-12T16:30:39Z",
            "errors": [
              "Received 404 response from the server."
            ],
            "warnings": [],
            "problem_summary": "404 error (page not found)",
            "suggested_fix": ""
          }
        ]
        )
      create(:link_report, batch_id: 2, step_id: step_item.id)
      expect(step_item.broken_links.length).to eql 1
    end
  end
end
