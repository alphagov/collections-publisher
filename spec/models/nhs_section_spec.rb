require "rails_helper"

RSpec.describe NhsSection, type: :model do
  describe "validations" do
    it { should validate_length_of(:heading).is_at_most(255) }
  end
end
