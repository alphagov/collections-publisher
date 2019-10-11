class PopulateAuthBypassId < ActiveRecord::Migration[5.2]
  class StepByStepPage < ActiveRecord::Base; end

  def up
    StepByStepPage.find_each do |step_by_step|
      auth_bypass_id = generate_legacy_auth_bypass_id(step_by_step.content_id)
      step_by_step.update_column(:auth_bypass_id, auth_bypass_id)
    end
  end

  def generate_legacy_auth_bypass_id(content_id)
    ary = Digest::SHA256.hexdigest(content_id.to_s).unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end
end
