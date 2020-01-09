require "rails_helper"

RSpec.feature "Curating topic contents" do
  include WaitForAjax

  before :each do
    stub_any_publishing_api_call
  end

  describe "Curating the content for a topic" do
    before :each do
      # Given a number of content items tagged to a topic
      oil_and_gas = create(:topic, :published, slug: "oil-and-gas", title: "Oil and Gas")
      topic = create(:topic, :published, slug: "offshore", title: "Offshore", parent: oil_and_gas)

      publishing_api_has_linked_items(
        topic.content_id,
        items: [
          { title: "Oil rig safety requirements", base_path: "/oil-rig-safety-requirements", content_id: "1f825f77-a82a-4c9c-ab88-78b8a5d9f836" },
          { title: "Oil rig staffing", base_path: "/oil-rig-staffing", content_id: "4646c58b-8bae-4fcb-b2bf-830716cae00c" },
          { title: "North sea shipping lanes", base_path: "/north-sea-shipping-lanes", content_id: "977d0edf-93c8-4049-9183-3d38554df0fa" },
          { title: "Undersea piping restrictions", base_path: "/undersea-piping-restrictions", content_id: "6a6b2955-52a9-4e99-aadb-b4430f92bb49" },
        ],
      )
    end

    it "with javascript", js: true do
      page.driver.browser.manage.window.resize_to(1366, 1000)
      # When I arrange the content of that topic into lists
      visit_topic_list_curation_page

      within "#new-list" do
        fill_in "Name", with: "Oil rigs"
        click_on "Create"
      end

      expect(page).to have_selector("h4", text: "Oil rigs")

      link_with_title("Oil rig staffing").drag_to droptarget_for_list("Oil rigs")
      wait_for_ajax
      link_with_title("Oil rig safety requirements").drag_to droptarget_for_list("Oil rigs")
      wait_for_ajax

      within :xpath, xpath_section_for("Oil rigs") do
        expect(page).to have_content("Oil rig safety requirements")
        expect(page).to have_content("Oil rig staffing")
        expect(page).not_to have_css(".working") # Wait until the AJAX call has completed
      end

      within "#new-list" do
        fill_in "Name", with: "Piping"
        click_on "Create"
      end

      expect(page).to have_selector(".list h4", text: "Piping")

      link_with_title("Undersea piping restrictions").drag_to droptarget_for_list("Piping")
      wait_for_ajax

      within :xpath, xpath_section_for("Piping") do
        expect(page).to have_content("Undersea piping restrictions")
        expect(page).not_to have_selector(".working") # Wait until the AJAX call has completed
      end

      # Then the content should be in the correct lists in the correct order
      visit_topic_list_curation_page

      within :xpath, xpath_section_for("Oil rigs") do
        expect(page).to have_selector("td.title", count: 2)
        titles = page.all("td.title").map(&:text)

        # Note: order reversed because we dragged the items to the top of the list above.
        expect(titles).to eq([
          "Oil rig staffing",
          "Oil rig safety requirements",
        ])
      end

      within :xpath, xpath_section_for("Piping") do
        titles = page.all("td.title").map(&:text)
        expect(titles).to eq([
          "Undersea piping restrictions",
        ])
      end

      # When I publish the topic
      content_id = extract_content_id_from(current_path)

      accept_confirm do
        click_on("Publish changes to GOV.UK")
      end

      # Necessary to re-visit the page here because accepting js confirmations
      # seem to complete after the spec has finished. This means that subsequent
      # expectations can fail or complete out-of-order. This arbitrary visit step
      # seems to allow all the expectations to run in order.
      visit_topic_list_curation_page

      #Then the curated lists should have been sent to the publishing API
      assert_publishing_api_put_content(
        content_id,
        request_json_includes(
          "details" => {
            "groups" => [
              { "name" => "Oil rigs",
                "contents" => [
                  "/oil-rig-staffing",
                  "/oil-rig-safety-requirements",
              ] },
              { "name" => "Piping",
                "contents" => [
                  "/undersea-piping-restrictions",
              ] },
            ],
            "internal_name" => "Oil and Gas / Offshore",
          },
        ),
      )

      # And have been published and links sent
      assert_publishing_api_publish(content_id)
      assert_publishing_api_patch_links(content_id)
    end

    it "without javascript" do
      # When I arrange the content of that topic into lists
      visit_topic_list_curation_page

      expect(page).to have_content("currently displayed in alphabetical order")

      within "#new-list" do
        fill_in "Name", with: "Oil rigs"
        click_on "Create"
      end

      within :xpath, xpath_section_for("Oil rigs") do
        fill_in "Base Path", with: "/oil-rig-safety-requirements"
        fill_in "Index", with: 0
        click_on "Add"

        fill_in "Base Path", with: "/oil-rig-staffing"
        fill_in "Index", with: 1
        click_on "Add"
      end

      within "#new-list" do
        fill_in "Name", with: "Piping"
        click_on "Create"
      end

      within :xpath, xpath_section_for("Piping") do
        fill_in "Base Path", with: "/undersea-piping-restrictions"
        fill_in "Index", with: 0
        click_on "Add"
      end

      # Then the content should be in the correct lists in the correct order
      visit_topic_list_curation_page
      content_id = extract_content_id_from(current_path)

      within :xpath, xpath_section_for("Oil rigs") do
        base_paths = page.all("tr").map { |tr| tr["data-base-path"] }.compact

        expect(base_paths).to eq([
          "/oil-rig-safety-requirements",
          "/oil-rig-staffing",
        ])
      end

      within :xpath, xpath_section_for("Piping") do
        base_paths = page.all("tr").map { |tr| tr["data-base-path"] }.compact

        expect(base_paths).to eq([
          "/undersea-piping-restrictions",
        ])
      end

      # When I publish the topic
      click_on("Publish changes to GOV.UK")

      #Then the curated lists should have been sent to the publishing API
      assert_publishing_api_put_content(
        content_id,
        request_json_includes(
          "details" => {
            "groups" => [
              { "name" => "Oil rigs",
                "contents" => [
                  "/oil-rig-safety-requirements",
                  "/oil-rig-staffing",
              ] },
              { "name" => "Piping",
                "contents" => [
                  "/undersea-piping-restrictions",
              ] },
            ],
            "internal_name" => "Oil and Gas / Offshore",
          },
        ),
      )

      # And then be published and links sent
      assert_publishing_api_publish(content_id)
      assert_publishing_api_patch_links(content_id)
    end
  end

  it "curating draft tags" do
    # Given a number of content items tagged to a draft topic
    oil_and_gas = create(:topic, :published, slug: "oil-and-gas", title: "Oil and Gas")
    topic = create(:topic, :draft, slug: "offshore", title: "Offshore", parent: oil_and_gas)

    publishing_api_has_linked_items(
      topic.content_id,
      items: [
        { base_path: "/oil-rig-safety-requirements", content_id: "0de31f13-08e5-4793-940d-f42e7087fe48" },
      ],
    )

    # Then I should be able to curate the draft topic
    visit_topic_list_curation_page

    # And I should not be able to publish the draft topic
    expect(page).not_to have_selector("button", text: "Publish")
    expect(page).not_to have_selector('input[type="submit"]', text: "Publish")
    expect(page).not_to have_selector('input[type="submit"][value="Publish"]')
  end

  context "with a subtopic which has had content curated" do
    before :each do
      oil_and_gas = create(:topic, :published, slug: "oil-and-gas", title: "Oil and Gas")
      offshore = create(:topic, :published, slug: "offshore", title: "Offshore", parent: oil_and_gas)

      publishing_api_has_linked_items(
        offshore.content_id,
        items: [
          { title: "Oil rig safety requirements", base_path: "/oil-rig-safety-requirements", content_id: "d1c574f1-9f1a-4d26-9af3-abb918e25319" },
          { title: "Oil rig staffing", base_path: "/oil-rig-staffing", content_id: "0437055c-c626-4543-b0f4-6c3ee38fdb0d" },
          { title: "North sea shipping lanes", base_path: "/north-sea-shipping-lanes", content_id: "5efc2e34-0131-4f4d-9296-7aa37d8f1031" },
          { title: "Undersea piping restrictions", base_path: "/undersea-piping-restrictions", content_id: "e8c756dc-6b10-46a5-8110-a1bb787dd319" },
        ],
      )

      oil_rigs = create(:list, tag: offshore, name: "Oil rigs", index: 0)
      piping = create(:list, tag: offshore, name: "Piping", index: 1)

      create(:list_item, list: oil_rigs, index: 0, base_path: "/oil-rig-safety-requirements")
      create(:list_item, list: oil_rigs, index: 1, base_path: "/oil-rig-staffing")
      create(:list_item, list: piping, index: 0, base_path: "/undersea-piping-restrictions")
      create(:list_item, list: piping, index: 1, title: "Non-existent", base_path: "/non-existent")
    end

    it "viewing the topic curation page" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # Then I should see the curated topic groups
      within ".curated-lists" do
        expect(list_titles_on_page).to eq([
          "Oil rigs",
          "Piping",
        ])

        within :xpath, xpath_section_for("Oil rigs") do
          titles = page.all("td.title").map(&:text)
          expect(titles).to eq([
            "Oil rig safety requirements",
            "Oil rig staffing",
          ])
        end

        within :xpath, xpath_section_for("Piping") do
          titles = page.all("td.title").map(&:text)
          expect(titles).to eq([
            "Undersea piping restrictions",
            "Tag was removed\nNon-existent",
          ])
        end
      end
    end

    it "editing a list name" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # And I change the name of a list
      within :xpath, xpath_section_for("Oil rigs") do
        click_on "Edit name"
      end

      fill_in "Name", with: "Oil platforms"
      click_on "Update list"

      # Then I should see the updated list name
      within ".curated-lists" do
        expect(list_titles_on_page).to eq([
          "Oil platforms",
          "Piping",
        ])
      end

      # And it should retain its content
      within :xpath, xpath_section_for("Oil platforms") do
        titles = page.all("td.title").map(&:text)
        expect(titles).to eq([
          "Oil rig safety requirements",
          "Oil rig staffing",
        ])
      end
    end

    it "deleting a list" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # And I delete a list
      within :xpath, xpath_section_for("Oil rigs") do
        find(".delete-list").click
      end

      # Then the list should be deleted
      within ".curated-lists" do
        expect(list_titles_on_page).to eq(%w(Piping))
      end

      # And the content from the list should appear in the uncategorized section
      within "#all-list-items" do
        titles = page.all("tbody td.title").map(&:text)
        expect(titles).to eq([
          "Oil rig safety requirements",
          "Oil rig staffing",
          "North sea shipping lanes",
          "Undersea piping restrictions",
        ])
      end
    end
  end

  def visit_topic_list_curation_page
    visit topics_path
    click_on "Offshore"
    find("#edit-list").click
  end

  def xpath_section_for(list_name)
    "//section[contains(@class, 'list')][contains(., '#{list_name}')]"
  end

  def droptarget_for_list(list_name)
    page.find(:xpath, xpath_section_for(list_name)).find("tbody")
  end

  def link_with_title(title)
    page.find(:xpath, ".//tr[.//td[@class='title'][contains(., '#{title}')]]")
  end

  def list_titles_on_page
    page.all(".list h4").map { |e| e.text.gsub(" Edit name", "") }
  end
end
