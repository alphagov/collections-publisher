require "rails_helper"

RSpec.describe TimelineEntry do
  it { should validate_presence_of(:heading) }
  it { should validate_presence_of(:content) }
end
