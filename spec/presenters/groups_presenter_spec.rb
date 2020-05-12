require "rails_helper"

RSpec.describe GroupsPresenter do
  describe "#groups" do
    let(:tag) do
      create(:tag, parent: create(:tag, slug: "oil-and-gas"),
                   slug: "offshore",
                   title: "Offshore",
                   description: "Oil rigs, pipelines etc.")
    end

    it "contains an empty groups array with no curated lists" do
      expect(GroupsPresenter.new(tag).groups).to eq([])
    end

    context "with some curated lists" do
      let(:oil_rigs) { create(:list, tag: tag, index: 1, name: "Oil rigs") }
      let(:piping) { create(:list, tag: tag, index: 0, name: "Piping") }

      it "provides the curated lists ordered by their index" do
        allow(oil_rigs).to receive(:tagged_list_items).and_return([
          OpenStruct.new(base_path: "/oil-rig-safety-requirements"),
          OpenStruct.new(base_path: "/oil-rig-staffing"),
        ])

        allow(piping).to receive(:tagged_list_items).and_return([
          OpenStruct.new(base_path: "/undersea-piping-restrictions"),
        ])

        allow(tag).to receive(:lists).and_return(double(ordered: [piping, oil_rigs]))

        expect(GroupsPresenter.new(tag).groups).to eq(
          [
            {
              name: "Piping",
              contents: [
                "/undersea-piping-restrictions",
              ],
            },
            {
              name: "Oil rigs",
              contents: [
                "/oil-rig-safety-requirements",
                "/oil-rig-staffing",
              ],
            },
          ],
        )
      end
    end
  end
end
