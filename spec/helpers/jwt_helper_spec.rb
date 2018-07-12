require "rails_helper"

RSpec.describe JwtHelper do
  describe "#auth_bypass_token" do
    it 'should create a predictable hex string based on the id' do
      expect(auth_bypass_token(123)).to eq("61363635-6134-4539-b230-343232663964")
    end
  end
end
