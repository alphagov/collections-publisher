require "rails_helper"

RSpec.describe SubSectionJsonPresenter do
  let(:label) { Faker::Lorem.sentence }
  let(:path) { "/#{File.join(Faker::Lorem.words)}" }
  let(:content) { "(#{label})[#{path}]" }

  let(:sub_section) { build :sub_section, content: content  }
  subject { described_class.new(sub_section) }

  describe '#title' do
    it 'returns the sub section title' do
      expect(subject.title).to eq(sub_section.title)
    end
  end

  describe '#content_sub_sections' do
    it 'contains the sub_section content if no title in content' do
      expect(subject.content_sub_sections).to eq([content])
    end

    context 'with many links' do
      let(:content) { "(this)[/this/path]\n(that)[/that/path]\n(foo)[foo/path]" }

      it 'returns them all in one element' do
        expect(subject.content_sub_sections).to eq([content])
      end
    end

    context 'with title then links' do
      let(:title) { "## Something" }
      let(:links) { "\n(that)[/that/path]\n(foo)[foo/path]" }
      let(:content) { title + links }

      it 'returns title and links separately' do
        expect(subject.content_sub_sections).to eq([title, links])
      end
    end

    context 'with titles within links' do
      let(:part_one) { "(foo)[foo/path]\n" }
      let(:part_two) { "## Something" }
      let(:part_three) { "\n(that)[/that/path]\n" }
      let(:part_four) { "## other" }
      let(:part_five) {"\n(#{label})[#{path}]" }
      let(:content) { [part_one, part_two, part_three, part_four, part_five].join }

      it 'returns the content in two parts' do
        expect(subject.content_sub_sections).to eq([part_one, part_two, part_three, part_four, part_five])
      end
    end
  end
end
