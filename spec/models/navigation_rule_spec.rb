require 'rails_helper'

RSpec.describe NavigationRule do
  let(:step_by_step_page) { create(:step_by_step_page) }

  it { belong_to :step_by_step_page }

  describe '#valid?' do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    context 'without a step_by_step_page' do
      it 'is invalid' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
        )

        expect(resource).to_not be_valid
        expect(resource.errors).to have_key(:step_by_step_page_id)
      end
    end

    context 'without a title' do
      it 'is invalid' do
        resource = described_class.new(
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          step_by_step_page: step_by_step_page,
        )

        expect(resource).to_not be_valid
        expect(resource.errors).to have_key(:title)
      end
    end

    context 'without a base_path' do
      it 'is invalid' do
        resource = described_class.new(
          title: 'A Title',
          content_id: 'A-CONTENT-ID-BOOM',
          step_by_step_page: step_by_step_page,
        )

        expect(resource).to_not be_valid
        expect(resource.errors).to have_key(:base_path)
      end
    end

    context 'without a content_id' do
      it 'is invalid' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          step_by_step_page: step_by_step_page,
        )

        expect(resource).to_not be_valid
        expect(resource.errors).to have_key(:content_id)
      end
    end

    context 'without a publishing_app' do
      it 'is invalid' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          step_by_step_page: step_by_step_page,
        )

        expect(resource).to_not be_valid
        expect(resource.errors).to have_key(:publishing_app)
      end
    end

    context 'without a schema_name' do
      it 'is invalid' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          step_by_step_page: step_by_step_page,
          publishing_app: 'transaction',
        )

        expect(resource).to_not be_valid
        expect(resource.errors).to have_key(:schema_name)
      end
    end

    context 'with valid attributes' do
      it 'is valid' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          step_by_step_page: step_by_step_page,
          publishing_app: 'publisher',
          schema_name: 'transaction'
        )

        expect(resource).to be_valid
        expect(resource.errors).to be_empty
      end
    end
  end

  describe '#smartanswer?' do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    it 'is a smartanswer start page' do
      resource = described_class.new(
        title: 'A Title',
        base_path: '/a-base-path',
        content_id: 'A-CONTENT-ID-BOOM',
        step_by_step_page: step_by_step_page,
        publishing_app: 'smartanswers',
        schema_name: 'transaction'
      )

      expect(resource.smartanswer?).to be true
    end

    it 'is not a smartanswer start page' do
      resource = described_class.new(
        title: 'A Title',
        base_path: '/a-base-path',
        content_id: 'A-CONTENT-ID-BOOM',
        step_by_step_page: step_by_step_page,
        publishing_app: 'publisher',
        schema_name: 'transaction'
      )

      expect(resource.smartanswer?).to be false
    end
  end

  describe '#options_with_selected' do
    context "include_in_links is set to always" do
      it 'returns an array of hashes, where selected is true for the always hash' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          include_in_links: 'always'
        )
        expected_options = [
          {
            text: "Always show navigation",
            value: "always",
            selected: true
          },
          {
            text: "Show navigation if user comes from a step-by-step",
            value: "conditionally",
            selected: false
          },
          {
            text: "Never show navigation",
            value: "never",
            selected: false
          }
        ]
        expect(resource.options_with_selected).to eq(expected_options)
      end
    end

    context "include_in_links is set to conditionally" do
      it 'returns an array of hashes, where selected is true for the conditionally hash' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          include_in_links: 'conditionally'
        )
        expected_options = [
          {
            text: "Always show navigation",
            value: "always",
            selected: false
          },
          {
            text: "Show navigation if user comes from a step-by-step",
            value: "conditionally",
            selected: true
          },
          {
            text: "Never show navigation",
            value: "never",
            selected: false
          }
        ]
        expect(resource.options_with_selected).to eq(expected_options)
      end
    end

    context "include_in_links is set to never" do
      it 'returns an array of hashes, where selected is true for the never hash' do
        resource = described_class.new(
          title: 'A Title',
          base_path: '/a-base-path',
          content_id: 'A-CONTENT-ID-BOOM',
          include_in_links: 'never'
        )
        expected_options = [
          {
            text: "Always show navigation",
            value: "always",
            selected: false
          },
          {
            text: "Show navigation if user comes from a step-by-step",
            value: "conditionally",
            selected: false
          },
          {
            text: "Never show navigation",
            value: "never",
            selected: true
          }
        ]
        expect(resource.options_with_selected).to eq(expected_options)
      end
    end
  end
end
