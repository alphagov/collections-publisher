require "rails_helper"

RSpec.describe TimelineEntry do
  it { should validate_presence_of(:heading) }
  it { should validate_length_of(:heading).is_at_most(255) }
  it { should validate_presence_of(:content) }
end
