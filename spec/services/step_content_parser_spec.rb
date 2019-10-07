require "rails_helper"

RSpec.describe StepContentParser do
  subject { described_class.new }

  context "#parse" do
    context "paragraphs" do
      it "a single line of text is parsed to an array with one paragraph section" do
        step_text = "This is a paragraph."

        expect(subject.parse(step_text)).to eq([
          {
            "type": "paragraph",
            "text": "This is a paragraph.",
          },
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
            "text": "These are all the right notes",
          },
          {
            "type": "paragraph",
            "text": "Just not necessarily in the right order",
          },
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
            "text": "Ladies and gentlemen:",
          },
          {
            "type": "paragraph",
            "text": "Grieg's piano concerto.",
          },
          {
            "type": "paragraph",
            "text": "By Grieg",
          },
          {
            "type": "paragraph",
            "text": "Conducted by Mr Andrew Preview",
          },
        ])
      end
    end

    context "list of bulleted links" do
      context 'and using "*" character for bullet points' do
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
                  "href": "/apply-provisional-licence",
                },
                {
                  "text": "Check that you can drive",
                  "href": "/vehicles-can-drive",
                },
              ],
            },
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
                  "href": "/speed-boat",
                },
                {
                  "text": "Spending money",
                  "href": "/spending-money",
                  "context": "£5000 or so",
                },
              ],
            },
          ])
        end
      end

      context 'and using "-" character for bullet points' do
        it "parses lists without links" do
          step_text = <<~HEREDOC
            - Apply for a provisional driving licence
          HEREDOC

          expect(subject.parse(step_text)).to eq([
            {
              "type": "list",
              "style": "choice",
              "contents": [
                {
                  "text": "Apply for a provisional driving licence",
                },
              ],
            },
          ])
        end

        it "is parsed to a 'choice' list of links" do
          step_text = <<~HEREDOC
            - [Apply for a provisional driving licence](/apply-provisional-licence)
            - [Check that you can drive](/vehicles-can-drive)
          HEREDOC

          expect(subject.parse(step_text)).to eq([
            {
              "type": "list",
              "style": "choice",
              "contents": [
                {
                  "text": "Apply for a provisional driving licence",
                  "href": "/apply-provisional-licence",
                },
                {
                  "text": "Check that you can drive",
                  "href": "/vehicles-can-drive",
                },
              ],
            },
          ])
        end

        it "is parsed to a 'choice' list of links with optional context" do
          step_text = <<~HEREDOC
            - [A speed boat](/speed-boat)
            - [Spending money](/spending-money)£5000 or so
          HEREDOC

          expect(subject.parse(step_text)).to eq([
            {
              "type": "list",
              "style": "choice",
              "contents": [
                {
                  "text": "A speed boat",
                  "href": "/speed-boat",
                },
                {
                  "text": "Spending money",
                  "href": "/spending-money",
                  "context": "£5000 or so",
                },
              ],
            },
          ])
        end
      end
    end

    context "list of non-bulleted links" do
      it "is parsed to a standard list of links" do
        step_text = <<~HEREDOC
          [Open the box](/open-the-box)
          [Keep the money](/keep-the-money)
        HEREDOC

        expect(subject.parse(step_text)).to eq([
          {
            "type": "list",
            "contents": [
              {
                "text": "Open the box",
                "href": "/open-the-box",
              },
              {
                "text": "Keep the money",
                "href": "/keep-the-money",
              },
            ],
          },
        ])
      end

      it "is parsed to a standard list of links with optional context" do
        step_text = <<~HEREDOC
          [A cuddly toy](/cuddly-toy)
          [Brucie bonus](/brucie-bonus)Mystery prize
        HEREDOC

        expect(subject.parse(step_text)).to eq([
          {
            "type": "list",
            "contents": [
              {
                "text": "A cuddly toy",
                "href": "/cuddly-toy",
              },
              {
                "text": "Brucie bonus",
                "href": "/brucie-bonus",
                "context": "Mystery prize",
              },
            ],
          },
        ])
      end
    end

    context "mixed content" do
      it "is parsed as expected" do
        step_text = <<~HEREDOC
          There are several prizes on offer on today's Generation Game conveyor belt including:

          [A cuddly toy](/cuddly-toy)
          [Brucie bonus](/brucie-bonus)Mystery prize

          If you get the mystery prize, this may be one of several things:

          * A speed boat
          - [A very expensive speed boat](/i-love-speed-boats)
          * [Spending money](/spending-money)£5000 or so
          - [A dishwasher](http://dishwashers.org/bargain-basement)
          - [I am a broken link]( ftp: / gov .uk)
          - And I'm a healthy bullet (although I eat ice cream everyday)

          [And I am also broken]()

          You have to remember them all!
        HEREDOC

        expect(subject.parse(step_text)).to eq([
          {
            "type": "paragraph",
            "text": "There are several prizes on offer on today's Generation Game conveyor belt including:",
          },
          {
            "type": "list",
            "contents": [
              {
                "text": "A cuddly toy",
                "href": "/cuddly-toy",
              },
              {
                "text": "Brucie bonus",
                "href": "/brucie-bonus",
                "context": "Mystery prize",
              },
            ],
          },
          {
            "type": "paragraph",
            "text": "If you get the mystery prize, this may be one of several things:",
          },
          {
            "type": "list",
            "style": "choice",
            "contents": [
              {
                "text": "A speed boat",
              },
              {
                "text": "A very expensive speed boat",
                "href": "/i-love-speed-boats",
              },
              {
                "text": "Spending money",
                "href": "/spending-money",
                "context": "£5000 or so",
              },
              {
                "text": "A dishwasher",
                "href": "http://dishwashers.org/bargain-basement",
              },
              {
                "text": "[I am a broken link]( ftp: / gov .uk)",
              },
              {
                "text": "And I'm a healthy bullet (although I eat ice cream everyday)",
              },
            ],
          },
          {
            "type": "paragraph",
            "text": "[And I am also broken]()",
          },
          {
            "type": "paragraph",
            "text": "You have to remember them all!",
          },
        ])
      end
    end
  end

  context "#base_paths" do
    it "text with no links is parsed to an empty array" do
      step_text = "This is a paragraph."

      expect(subject.base_paths(step_text)).to eq([])
    end

    it "rejects fully qualified urls that are not GOV.UK" do
      step_text = <<~HEREDOC
        [All the prizes](/all-the-prizes)
        - [A gondola trip for two](https://gondolier-r-us.com/default.asp)
        - [A very expensive speed boat](/i-love-speed-boats)
        - [Spending money](/spending-money)£5000 or so
        - [A dishwasher](HTTP://dishwashers.org/bargain-basement)
      HEREDOC

      expect(subject.base_paths(step_text)).to eq(
        %w(
          /all-the-prizes
          /i-love-speed-boats
          /spending-money
        ),
      )
    end

    it "allows fully qualified GOV.UK urls" do
      step_text = <<~HEREDOC
        - [Insecure link         ](http://gov.uk/insecure-link)
        - [Secure link           ](https://gov.uk/secure-link)
        - [Insecure link with www](http://www.gov.uk/insecure-link-with-www)
        - [Secure link with www  ](https://www.gov.uk/secure-link-with-www)
      HEREDOC

      expect(subject.base_paths(step_text)).to eq(
        %w(
          /insecure-link
          /secure-link
          /insecure-link-with-www
          /secure-link-with-www
        ),
      )
    end

    it "rejects invalid URLs" do
      step_text = <<~HEREDOC
        [All the prizes](/all-the-prizes)
        - [A link with a space prefix]( /foo)
        - [A link with a space suffix](/i-love-speed-boats )
        - [An invalid link](ftp:/ gov . uk)
        - [A dishwasher](/bargain-basement)
      HEREDOC

      expect(subject.base_paths(step_text)).to eq(
        %w(
          /all-the-prizes
          /bargain-basement
        ),
      )
    end

    it "can cope with multiple links per line" do
      step_text = "[Find driving instructor training courses](/find-driving-instructor-training)[Revise and practise for your test](/adi-part-1-test/revision-practice)"

      expect(subject.base_paths(step_text.chomp)).to eq(
        %w(
          /find-driving-instructor-training
          /adi-part-1-test/revision-practice
        ),
      )
    end

    it "strips query strings and segments" do
      step_text = <<~HEREDOC
        [All the prizes](/all-the-prizes#the-best-ones)
        - [A very expensive speed boat](/i-love-speed-boats)
        - [Spending money](/spending-money?currency=sterling)£5000 or so
      HEREDOC

      expect(subject.base_paths(step_text)).to eq(
        %w(
          /all-the-prizes
          /i-love-speed-boats
          /spending-money
        ),
      )
    end

    it "can cope with weird things" do
      step_text = <<~HEREDOC
        Some text with a [link in the middle](/the-only/Server-Relative/path/in-here)
        [All the prizes](\\all-the-prizes/#the-best-ones)
        - [A very expensive speed boat](//i-love-speed-boats)
        - [Spending money](spending-money?currency=sterling)£5000 or so
        - [Other things](/apart-from-this-one) And some trailing text with a (set of parens) in it
      HEREDOC

      expect(subject.base_paths(step_text)).to eq(
        %w(
          /the-only/Server-Relative/path/in-here
          /apart-from-this-one
        ),
      )
    end
  end

  context "mixed content" do
    it "handles different line endings" do
      step_text = "Paragraphs are separated by empty lines.\r\n\r\nUse non-bulleted lists for tasks. Add any costs after the link:\r\n\r\n[task name](/link) £10 to £20\r\n[task name](/link)\r\n\r\nOnly use bullets to show when a task has a number of options to choose from:\r\n\r\n- [download form option 1](/link)\r\n- [download form option 2](/link)\r\n- bullet with no link"

      expect(
        subject.parse(step_text),
      ).to eql([
        {
          "type": "paragraph",
          "text": "Paragraphs are separated by empty lines.",
        },
        {
          "type": "paragraph",
          "text": "Use non-bulleted lists for tasks. Add any costs after the link:",
        },
        {
          "type": "list",
          "contents": [
            {
              "text": "task name",
              "href": "/link",
              "context": "£10 to £20",
            },
            {
              "text": "task name",
              "href": "/link",
            },
          ],
        },
        {
          "type": "paragraph",
          "text": "Only use bullets to show when a task has a number of options to choose from:",
        },
        {
          "type": "list",
          "style": "choice",
          "contents": [
            {
              "text": "download form option 1",
              "href": "/link",
            },
            {
              "text": "download form option 2",
              "href": "/link",
            },
            {
              "text": "bullet with no link",
            },
          ],
        },
      ])
    end

    it "extracts relative links from extended content" do
      step_text = <<~HEREDOC
        There are several prizes on offer on today's Generation Game conveyor belt including:
        [A cuddly toy](/cuddly-toy)
        [Brucie bonus](/brucie-bonus)Mystery prize
        If you get the mystery prize, this may be one of several things:
        * A speed boat
        - [A very expensive speed boat](/i-love-speed-boats/big-ones)
        * [Spending money](/spending-money)£5000 or so
        - [A dishwasher](http://dishwashers.org/bargain-basement)
        - And I'm a healthy bullet (although I eat ice cream everyday)
        You have to remember them all!
      HEREDOC

      expect(subject.base_paths(step_text)).to eq(
        %w(
          /cuddly-toy
          /brucie-bonus
          /i-love-speed-boats/big-ones
          /spending-money
        ),
      )
    end
  end

  describe ".all_paths" do
    context "when there are no links in the text" do
      test_text = "Lorem ipsum dolores"
      it "should return an empty array" do
        expect(subject.all_paths(test_text)).to be_empty
      end
    end
    context "when there is one relative and one absolute path" do
      test_text = "[Learn to drive](/learn-to-drive)\n[Google it](https://www.google.com)"
      it "should return an array of URLs" do
        links = subject.all_paths(test_text)
        expect(links).to all(start_with("https:"))
      end
      it "should have a length of two" do
        links = subject.all_paths(test_text)
        expect(links.length).to eql 2
      end
    end
  end
end
