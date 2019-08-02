require 'rails_helper'

RSpec.describe "Panel", type: :view do
  it "fails to render when no data is given" do
    assert_raises do
      render("components/panel", {})
    end
  end

  it "renders a panel component with title and body" do
    render "components/panel", title: 'Application complete', body: 'Body'

    assert_select ".app-c-panel__title", text: 'Application complete'
    assert_select ".govuk-body", text: 'Body'
  end
end
