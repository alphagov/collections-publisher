require "rails_helper"

RSpec.describe PatternMaker do
  let(:description) { "foo" }
  let(:options) { {} }
  let(:predefined_patterns) { described_class::PATTERNS }
  let(:pattern_name) { predefined_patterns.keys.sample }
  let(:first) { predefined_patterns.keys.first }
  let(:last) { predefined_patterns.keys.last }

  describe ".call" do
    subject(:pattern) { described_class.call(description, options) }

    it "returns the input if no match" do
      expect(pattern).to eq(Regexp.new(description))
    end

    context "with an existing pattern" do
      let(:description) { pattern_name.to_s }

      it "returns the matching pattern" do
        expect(pattern).to eq(Regexp.new(predefined_patterns[pattern_name]))
      end
    end

    context "multiple patterns" do
      let(:description) { "#{first} #{last}" }

      it "concatenates the patterns" do
        expect(pattern).to eq(Regexp.new(predefined_patterns[first] + predefined_patterns[last]))
      end
    end

    context 'with "then" key word' do
      let(:description) { "#{first} then #{last}" }

      it "concatenates the patterns and ignores the key word" do
        expect(pattern).to eq(Regexp.new(predefined_patterns[first] + predefined_patterns[last]))
      end
    end

    context 'with "and" key word' do
      let(:description) { "#{first} and #{last}" }

      it "concatenates the patterns and ignores the key word" do
        expect(pattern).to eq(Regexp.new(predefined_patterns[first] + predefined_patterns[last]))
      end
    end

    context "using within" do
      let(:description) { "within(brackets,foo)" }

      it "wraps the output with the matching escaped parenthesis" do
        expect(pattern).to eq(/\(foo\)/)
      end
    end

    context "using capture" do
      let(:description) { "capture(foo)" }

      it "marks the pattern as a named capture" do
        expect(pattern).to eq(/(?<foo>foo)/)
      end
    end

    context "with pattern option" do
      let(:options) { { option: "some option" } }
      let(:description) { "option" }

      it "returns the matching pattern" do
        expect(pattern).to eq(Regexp.new(options[:option]))
      end
    end

    context "with multiple elements and key words" do
      let(:description) { "starts_with within(sq_brackets,words) then perhaps_spaces and capture(anything)" }

      it "combines the result" do
        expect(pattern).to eq(/^\[\w[\w\s.,]+\]\s*(?<anything>.*)/)
      end
    end
  end
end
