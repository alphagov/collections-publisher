require "rails_helper"

RSpec.describe TagArchiver do
  describe '#archive' do
    before do
      stub_any_publishing_api_call

      allow(Services.publishing_api).to receive(:put_content)
    end

    it "won't archive parent tags" do
      tag = create(:topic, :published)

      expect { TagArchiver.new(tag, build(:topic)).archive }.to raise_error(RuntimeError)
    end

    it "archives the tag" do
      tag = create(:topic, :published, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive
      tag.reload

      expect(tag.archived?).to be(true)
    end

    it "creates a redirect to its successor" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = create(:topic)

      TagArchiver.new(tag, successor).archive
      redirect = tag.redirect_routes.first

      expect(redirect.from_base_path).to eql tag.base_path
      expect(redirect.to_base_path).to eql successor.base_path
    end

    it "creates a redirect to its non-topic successor" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = OpenStruct.new(base_path: "www.gov.uk/successor", subroutes: [])

      TagArchiver.new(tag, successor).archive
      redirect = tag.redirect_routes.first

      expect(redirect.from_base_path).to eql tag.base_path
      expect(redirect.to_base_path).to eql successor.base_path
    end

    it "creates redirects for the suffixes" do
      tag = create(:topic, :published, slug: 'bar', parent: create(:topic, slug: 'foo'))
      successor = create(:topic)

      TagArchiver.new(tag, successor).archive

      expect(tag.redirect_routes.map(&:from_base_path)).to eql([
        "/topic/foo/bar",
        "/topic/foo/bar/latest",
        "/topic/foo/bar/email-signup",
      ])
    end

    it "redirects to the base path when the successor is a parent topic" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = create(:topic, slug: 'foo')

      TagArchiver.new(tag, successor).archive

      expect(tag.redirect_routes.map(&:to_base_path)).to eql([
        "/topic/foo",
        "/topic/foo",
        "/topic/foo",
      ])
    end

    it "redirects to the suffixes when the successor is a child topic" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = create(:topic, slug: 'bar', parent: create(:topic, slug: 'foo'))

      TagArchiver.new(tag, successor).archive

      expect(tag.redirect_routes.map(&:to_base_path)).to eql([
        "/topic/foo/bar",
        "/topic/foo/bar/latest",
        "/topic/foo/bar/email-signup",
      ])
    end

    it "republishes the content item" do
      tag = create(:topic, :published, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive

      expect(Services.publishing_api).to have_received(:put_content)
    end

    it "doesn't have side effects when a API call fails" do
      tag = create(:topic, :published, parent: create(:topic))

      expect(Services.publishing_api).to receive(:put_content).and_raise('publishing API call failed')
      expect { TagArchiver.new(tag, build(:topic)).archive }.to raise_error('publishing API call failed')
      tag.reload

      expect(tag.archived?).to be(false)
      expect(tag.redirect_routes.size).to be(0)
    end
  end
end
