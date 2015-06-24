require "rails_helper"
require "#{Rails.root}/db/migrate/20150622073727_add_redirects_for_topics_namespace"

RSpec.describe AddRedirectsForTopicsNamespace do
  describe '#up' do
    it 'creates redirects for published parent topics' do
      create(:topic, :draft, slug: 'foo')
      create(:topic, :published, slug: 'draft-foo')

      AddRedirectsForTopicsNamespace.new.up

      expect(Redirect.count).to eql(1)
    end

    it 'creates the correct parent redirects' do
      topic = create(:topic, :published, slug: 'foo')

      AddRedirectsForTopicsNamespace.new.up
      redirect = Redirect.last

      expect(redirect.tag).to eql(topic)
      expect(redirect.original_topic_base_path).to eql('/foo')
      expect(redirect.from_base_path).to eql('/foo')
      expect(redirect.to_base_path).to eql('/topic/foo')
    end

    it 'creates redirects for parent topics' do
      parent = create(:topic, :published, slug: 'foo')
      child = create(:topic, :published, parent: parent, slug: 'bar')
      child = create(:topic, :draft, parent: parent, slug: 'draft-bar')

      AddRedirectsForTopicsNamespace.new.up

      expect(Redirect.count).to eql(4)
    end

    it 'creates the child topic redirects' do
      parent = create(:topic, :published, slug: 'foo')
      child = create(:topic, :published, parent: parent, slug: 'bar')

      AddRedirectsForTopicsNamespace.new.up

      expect(child.redirects.map(&:from_base_path)).to eql(
        [ "/foo/bar",
          "/foo/bar/email-signup",
          "/foo/bar/latest"]
      )

      expect(child.redirects.map(&:to_base_path)).to eql(
        [ "/topic/foo/bar",
          "/topic/foo/bar/email-signup",
          "/topic/foo/bar/latest"]
      )
    end
  end
end
