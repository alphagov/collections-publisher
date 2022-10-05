require "rails_helper"

RSpec.describe Coronavirus::Page do
  describe "validations" do
    let(:page) { create :coronavirus_page }

    describe "state validations" do
      it "has a default state when created" do
        expect(page.state).to eq "draft"
      end

      it "state cannot be nil" do
        page.state = ""
        expect(page).not_to be_valid
      end

      it "state must be draft or published" do
        page.state = "lovely"
        expect(page).not_to be_valid
      end
    end

    describe "header section validations" do
      it { should validate_length_of(:header_title).is_at_most(255) }
      it { should validate_length_of(:header_link_pre_wrap_text).is_at_most(255) }
      it { should validate_length_of(:header_link_post_wrap_text).is_at_most(255) }

      describe "header_link_url validation" do
        it { should allow_values("/path", "https://example.com").for(:header_link_url) }
        it { should_not allow_values("not a url").for(:header_link_url) }

        it "doesn't apply the URL format validation when the field is blank" do
          page.header_link_url = ""
          expect(page).to be_valid
        end
      end

      describe "header_link_post_wrap_text validation" do
        it "is not valid if present whilst header_link_pre_wrap_text is blank" do
          page.header_link_pre_wrap_text = ""
          page.header_link_post_wrap_text = "post wrap link text"
          expect(page).not_to be_valid
        end
      end

      describe "header link url and text validation" do
        it "is valid if both header_link_url and header_link_pre_wrap_text are present" do
          page.header_link_url = "/path"
          page.header_link_pre_wrap_text = "Text"
          expect(page).to be_valid
        end

        it "is valid if neither header_link_url and header_link_pre_wrap_text are present" do
          page.header_link_url = ""
          page.header_link_pre_wrap_text = ""
          expect(page).to be_valid
        end

        it "is not valid if header_link_url is present, but header_link_pre_wrap_text is not" do
          page.header_link_url = "/path"
          page.header_link_pre_wrap_text = ""
          expect(page).to_not be_valid
        end

        it "is not valid if header_link_pre_wrap_text is present, but header_link_url is not" do
          page.header_link_url = ""
          page.header_link_pre_wrap_text = "Text"
          expect(page).to_not be_valid
        end
      end
    end
  end

  describe "dependencies" do
    let!(:page) { create :coronavirus_page }
    let!(:sub_section) { create :coronavirus_sub_section, page: }

    it "deletion destroys all child subsections" do
      expect { page.destroy }
        .to change { Coronavirus::SubSection.count }.by(-1)
    end
  end
end
