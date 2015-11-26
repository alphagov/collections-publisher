require 'rails_helper'

RSpec.describe ArchivedTagPresenter do

  let(:parent)   { create :topic, slug: 'parent', title: 'Parent topic', description: 'Description of parent topic.' }
  let(:child)    { create :topic, slug: 'child-1', title: 'Child topic', description: 'Description of child topic.', parent: parent }

  describe '#render_for_publishing_api' do
    before(:each) do
      %w{ child-1 child-1/latest child-1/email-signup }.each do |route|
        child.redirect_routes.create!(from_base_path: "/topic/parent/#{route}", to_base_path: parent.base_path, tag_id: child.id)
      end
    end

    it 'renders a redirect to a parent with no subroutes correctly' do
      expected_child_content = {
        content_id: child.content_id,
        base_path: "/topic/parent/child-1",
        format: "redirect",
        publishing_app: "collections-publisher",
        update_type: "major",
        redirects: [
          {
            path: "/topic/parent/child-1",
            destination: "/topic/parent",
            type: "exact"
          },
          {
            path: "/topic/parent/child-1/latest",
            destination: "/topic/parent",
            type: "exact"
          },
          {
            path: "/topic/parent/child-1/email-signup",
            destination: "/topic/parent",
            type: "exact"
          },
        ]
      }
      presenter = ArchivedTagPresenter.new(child)
      expect(presenter.render_for_publishing_api).to eq expected_child_content
    end
  end

  describe '#base_path' do
    it 'should return the original tag base path' do
      presenter = ArchivedTagPresenter.new(child)
      expect(presenter.base_path).to eq child.base_path
    end
  end
end
