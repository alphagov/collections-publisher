# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  email               :string(255)
#  uid                 :string(255)      not null
#  organisation_slug   :string(255)
#  permissions         :string(255)
#  remotely_signed_out :boolean          default(FALSE)
#  disabled            :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_uid  (uid) UNIQUE
#

require 'rails_helper'

require 'gds-sso/lint/user_spec'

RSpec.describe User do
  it_behaves_like "a gds-sso user class"
end
