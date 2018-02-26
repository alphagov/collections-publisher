require 'rails_helper'

RSpec.describe StepContentParser do
  subject { described_class.new }

  context "paragraphs" do
    it "a single line of text is parsed to an array with one paragraph section" do
      step_text = "This is a paragraph."

      expect(subject.parse(step_text)).to eq([
        {
          "type": "paragraph",
          "text": "This is a paragraph."
        }
      ])
    end

    it "Generates multiple paragraphs if they are separated by blank lines" do
      step_text = <<~HEREDOC
        These are all the right notes

        Just not necessarily in the right order
      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "paragraph",
          "text": "These are all the right notes"
        },
        {
          "type": "paragraph",
          "text": "Just not necessarily in the right order"
        }
      ])
    end
  end

  context "list of bulleted links" do
    it "is parsed to a 'choice' list of links" do
      step_text = <<~HEREDOC
        * [Apply for a provisional driving licence](/apply-provisional-licence)
        * [Check that you can drive](/vehicles-can-drive)
      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "list",
          "style": "choice",
          "contents": [
            {
              "href": "/apply-provisional-licence",
              "text": "Apply for a provisional driving licence"
            },
            {
              "href": "/vehicles-can-drive",
              "text": "Check that you can drive"
            }
          ]
        }
      ])
    end
  end

  context "list of non-bulleted links" do
    it "is parsed to a standard list of links" do
      step_text = <<~HEREDOC
        - [Open the box](/open-the-box)
        - [Keep the money](/keep-the-money)
      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "list",
          "contents": [
            {
              "href": "/open-the-box",
              "text": "Open the box"
            },
            {
              "href": "/keep-the-money",
              "text": "Keep the money"
            }
          ]
        }
      ])
    end
  end
end
