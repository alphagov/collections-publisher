require 'rails_helper'

RSpec.describe SecondaryContentLink do
  let(:step_by_step_page) { create(:step_by_step_page_with_secondary_content) }
  let(:secondary_content_link) { build(:secondary_content_link, step_by_step_page: step_by_step_page) }

  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  describe "validations" do
    it 'should belong to a step_by_step_page' do
      should validate_presence_of(:step_by_step_page)
    end

    it 'fails if step_by_step_page does not exist' do
      secondary_content_link.step_by_step_page = nil

      expect(secondary_content_link).not_to be_valid
    end

    it 'requires a title' do
      secondary_content_link.title = ''

      expect(secondary_content_link).not_to be_valid
      expect(secondary_content_link.errors).to have_key(:title)
    end

    it 'requires a base_path' do
      secondary_content_link.base_path = ''

      expect(secondary_content_link).not_to be_valid
      expect(secondary_content_link.errors).to have_key(:base_path)
    end

    it 'requires a content_id' do
      secondary_content_link.content_id = ''

      expect(secondary_content_link).not_to be_valid
      expect(secondary_content_link.errors).to have_key(:content_id)
    end

    it 'requires a publishing_app' do
      secondary_content_link.publishing_app = ''

      expect(secondary_content_link).not_to be_valid
      expect(secondary_content_link.errors).to have_key(:publishing_app)
    end

    it 'requires a schema_name' do
      secondary_content_link.schema_name = ''

      expect(secondary_content_link).not_to be_valid
      expect(secondary_content_link.errors).to have_key(:schema_name)
    end

    describe '#base_path' do
      it 'is created with valid attributes when the base_path is unique to the step_by_step_page' do
        secondary_content_link = build(
          :secondary_content_link,
          step_by_step_page: step_by_step_page,
          base_path: "/same-step-by-step/shiny-new-path"
        )
        expect(secondary_content_link).to be_valid
        expect(secondary_content_link.save).to eql true
        expect(secondary_content_link).to be_persisted
      end

      it 'returns an error when the base_path and step_by_step_page are not unique' do
        expect(secondary_content_link.save).to be false
        expect(secondary_content_link.errors.count).to eq(1)
      end
    end
  end

  describe '#smartanswer?' do
    it 'is not a smartanswer start page' do
      expect(secondary_content_link.smartanswer?).to be false
    end

    it 'is a smartanswer start page' do
      secondary_content_link = build(
        :secondary_content_link,
        step_by_step_page: step_by_step_page,
        publishing_app: "smartanswers",
        schema_name: "transaction",
      )

      expect(secondary_content_link.smartanswer?).to be true
    end
  end
end
