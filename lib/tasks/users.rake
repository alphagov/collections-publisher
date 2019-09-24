namespace :users do
  desc 'Delete "Edit Taxonomy" permissions from users'
  task remove_edit_taxonomy_permission: :environment do
    User.transaction do
      User.all.each do |user|
        permission = "Edit Taxonomy"
        Rails.logger.info "Removing '#{permission}' permission from #{user.email}"
        result = PermissionRemover.run(permission: permission, user: user)
        raise "Unable to save user record, aborting" if result == PermissionRemover::FAILURE
      end
    end
  end
end
