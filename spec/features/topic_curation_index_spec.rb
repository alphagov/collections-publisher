require 'rails_helper'

RSpec.describe "topic curation index" do

  it "shows all subtopics grouped by parent" do

    b = create(:topic, :title => "Bravo", :slug => "bravo")
    a = create(:topic, :title => "Alpha", :slug => "alpha")
    c = create(:topic, :title => "Charlie", :slug => "charlie")

    a_a = create(:topic, :title => "Alpha Alpha", :slug => "alpha", :parent => a)
    a_c = create(:topic, :title => "Alpha Charlie", :slug => "charlie", :parent => a)
    a_b = create(:topic, :title => "Alpha Bravo", :slug => "bravo", :parent => a)
    b_a = create(:topic, :title => "Bravo Alpha", :slug => "alpha", :parent => b)
    b_b = create(:topic, :title => "Bravo Bravo", :slug => "bravo", :parent => b)


    visit "/sectors"

    within 'table.topics' do
      parents = page.all('tbody tr.parent-tag th').map(&:text)
      expect(parents).to eq([
        'Alpha',
        'Bravo',
      ])

      subtopics = page.all('tbody tr td:first-child').map(&:text)
      expect(subtopics).to eq([
        'Alpha Alpha',
        'Alpha Bravo',
        'Alpha Charlie',
        'Bravo Alpha',
        'Bravo Bravo',
      ])
    end
  end
end
