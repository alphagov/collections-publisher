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

    it "generates multiple paragraphs if they are separated by blank lines" do
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

    it "copes with multiple blank lines and trailing blank lines" do
      step_text = <<~HEREDOC
        Ladies and gentlemen:


        Grieg's piano concerto.


        By Grieg

        Conducted by Mr Andrew Preview

      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "paragraph",
          "text": "Ladies and gentlemen:"
        },
        {
          "type": "paragraph",
          "text": "Grieg's piano concerto."
        },
        {
          "type": "paragraph",
          "text": "By Grieg"
        },
        {
          "type": "paragraph",
          "text": "Conducted by Mr Andrew Preview"
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
              "text": "Apply for a provisional driving licence",
              "href": "/apply-provisional-licence"
            },
            {
              "text": "Check that you can drive",
              "href": "/vehicles-can-drive"
            }
          ]
        }
      ])
    end

    it "is parsed to a 'choice' list of links with optional context" do
      step_text = <<~HEREDOC
        * [A speed boat](/speed-boat)
        * [Spending money](/spending-money)£5000 or so
      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "list",
          "style": "choice",
          "contents": [
            {
              "text": "A speed boat",
              "href": "/speed-boat"
            },
            {
              "text": "Spending money",
              "href": "/spending-money",
              "context": "£5000 or so"
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
              "text": "Open the box",
              "href": "/open-the-box"
            },
            {
              "text": "Keep the money",
              "href": "/keep-the-money"
            }
          ]
        }
      ])
    end

    it "is parsed to a standard list of links with optional context" do
      step_text = <<~HEREDOC
        - [A cuddly toy](/cuddly-toy)
        - [Brucie bonus](/brucie-bonus)Mystery prize
      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "list",
          "contents": [
            {
              "text": "A cuddly toy",
              "href": "/cuddly-toy"
            },
            {
              "text": "Brucie bonus",
              "href": "/brucie-bonus",
              "context": "Mystery prize"
            }
          ]
        }
      ])
    end
  end

  context "mixed content" do
    it "handles different line endings" do
      step_text = "Paragraphs are separated by empty lines.\r\n\r\nThis is a list of bulleted links...\r\n\r\n* [Link text](/link/href/value)\r\n* [Link text](/link/href/value)\r\n\r\nThis is a list of non-bulleted links...\r\n\r\n- [Link text](/link/href/value)\r\n- [Link text](/link/href/value)"

      expect(subject.parse(step_text)).to eq([
        {
          "type": "paragraph",
          "text": "Paragraphs are separated by empty lines."
        },
        {
          "type": "paragraph",
          "text": "This is a list of bulleted links..."
        },
        {
          "type": "list",
          "style": "choice",
          "contents": [
            {
              "text": "Link text",
              "href": "/link/href/value"
            },
            {
              "text": "Link text",
              "href": "/link/href/value"
            }
          ]
        },
        {
          "type": "paragraph",
          "text": "This is a list of non-bulleted links..."
        },
        {
          "type": "list",
          "contents": [
            {
              "text": "Link text",
              "href": "/link/href/value"
            },
            {
              "text": "Link text",
              "href": "/link/href/value"
            }
          ]
        },
      ])
    end

    it "is parsed as expected" do
      step_text = <<~HEREDOC
        There are several prizes on offer on today's Generation Game conveyor belt including:

        - [A cuddly toy](/cuddly-toy)
        - [Brucie bonus](/brucie-bonus)Mystery prize

        If you get the mystery prize, this may be one of several things:

        * [A speed boat](/speed-boat)
        * [Spending money](/spending-money)£5000 or so
        * [A dishwasher](http://dishwashers.org/bargain-basement)

        You have to remember them all!
      HEREDOC

      expect(subject.parse(step_text)).to eq([
        {
          "type": "paragraph",
          "text": "There are several prizes on offer on today's Generation Game conveyor belt including:"
        },
        {
          "type": "list",
          "contents": [
            {
              "text": "A cuddly toy",
              "href": "/cuddly-toy"
            },
            {
              "text": "Brucie bonus",
              "href": "/brucie-bonus",
              "context": "Mystery prize"
            }
          ]
        },
        {
          "type": "paragraph",
          "text": "If you get the mystery prize, this may be one of several things:"
        },
        {
          "type": "list",
          "style": "choice",
          "contents": [
            {
              "text": "A speed boat",
              "href": "/speed-boat"
            },
            {
              "text": "Spending money",
              "href": "/spending-money",
              "context": "£5000 or so"
            },
            {
              "text": "A dishwasher",
              "href": "http://dishwashers.org/bargain-basement"
            }
          ]
        },
        {
          "type": "paragraph",
          "text": "You have to remember them all!"
        }
      ])
    end
  end
end
