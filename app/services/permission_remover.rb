class PermissionRemover
  SUCCESS = 0
  FAILURE = 1

  attr_reader :permission, :user

  def self.run(permission:, user:)
    new(permission:, user:).run
  end

  def initialize(permission:, user:)
    @permission = permission
    @user = user
  end

  def run
    return SUCCESS unless user.permissions.include?(permission)

    user.permissions.delete(permission)
    user.save ? SUCCESS : FAILURE
  end
end
