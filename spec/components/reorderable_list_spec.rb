require "rails_helper"

RSpec.describe "Reorderable list", type: :view do
  def render_component(arguments)
    render partial: "components/reorderable_list", locals: arguments
  end

  def items
    [
      {
        id: "item-1",
        title: "Budget 2018",
        description: "PDF, 2.56MB, 48 pages",
      },
      {
        id: "item-2",
        title: "Budget 2018 (web)",
        description: "HTML attachment",
      },
      {
        id: "item-3",
        title: "Impact on households: distributional analysis to accompany Budget 2018",
        description: "PDF, 592KB, 48 pages",
      },
      {
        id: "item-3",
        title: "Table 2.1: Budget 2018 policy decisions",
        description: "MS Excel Spreadsheet, 248KB",
      },
      {
        id: "item-3",
        title: "Table 2.2: Measures announced at Autumn Budget 2017 or earlier that will take effect from November 2018 or later (£ million)",
        description: "MS Excel Spreadsheet, 248KB",
      },
    ]
  end

  it "renders a list of items" do
    render_component(items: items)

    assert_select ".app-c-reorderable-list"
    assert_select ".app-c-reorderable-list__item", 5
    assert_select ".app-c-reorderable-list__item" do |elements|
      elements.each_with_index do |element, index|
        assert_select element, ".app-c-reorderable-list__title", { text: items[index][:title] }
        assert_select element, ".app-c-reorderable-list__description", { text: items[index][:description] }
        assert_select element, ".app-c-reorderable-list__actions"
        assert_select element, ".app-c-reorderable-list__actions .js-reorderable-list-up", { text: "Up" }
        assert_select element, ".app-c-reorderable-list__actions .js-reorderable-list-down", { text: "Down" }
        assert_select element, ".app-c-reorderable-list__actions input[name='ordering[#{items[index][:id]}]']"
        assert_select element, ".app-c-reorderable-list__actions input[value='#{index + 1}']"
      end
    end
  end

  it "renders allows custom input names" do
    render_component(items: items, input_name: "attachments[ordering]")

    assert_select ".app-c-reorderable-list"
    assert_select ".app-c-reorderable-list__item" do |elements|
      elements.each_with_index do |element, index|
        assert_select element, ".app-c-reorderable-list__actions input[name='attachments[ordering][#{items[index][:id]}]']"
      end
    end
  end
end
