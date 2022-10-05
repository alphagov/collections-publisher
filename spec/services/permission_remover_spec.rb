require "rails_helper"

RSpec.describe PermissionRemover do
  subject { described_class.new(permission:, user:) }
  let(:permission) { "My Permission" }

  context "without the permission present" do
    let(:user) { create(:user, permissions: []) }

    it "is successful" do
      expect(subject.run).to eq(PermissionRemover::SUCCESS)
    end
  end

  context "with an error saving the user" do
    let(:user) { create(:user, permissions: ["My Permission"]) }

    before do
      expect(user).to receive(:save).and_return(false)
    end

    it "is not successful" do
      expect(subject.run).to eq(PermissionRemover::FAILURE)
    end
  end

  context "with the permission present" do
    let(:user) { create(:user, permissions: ["My Permission"]) }

    it "it returns wether the user record was correctly saved" do
      expect(subject.run).to eq(PermissionRemover::SUCCESS)
    end

    it "removes the permission" do
      subject.run
      expect(user.reload.permissions).to be_empty
    end
  end
end
