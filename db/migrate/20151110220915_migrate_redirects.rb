class MigrateRedirects < ActiveRecord::Migration
  class LegacyRedirect < ActiveRecord::Base
    self.table_name = 'redirects'
  end

  def up
    LegacyRedirect.find_each do |legacy_redirect|
      new_redirect = Redirect.find_or_create_by(
        original_tag_base_path: legacy_redirect.original_tag_base_path,
        tag_id: legacy_redirect.tag_id
      )

      new_redirect.update_columns(
        created_at: legacy_redirect.created_at,
        updated_at: legacy_redirect.updated_at
      )

      redirect_route = RedirectRoute.create!(
        redirect: new_redirect,
        from_base_path: legacy_redirect.from_base_path,
        to_base_path: legacy_redirect.to_base_path
      )

      redirect_route.update_columns(
        created_at: legacy_redirect.created_at,
        updated_at: legacy_redirect.updated_at
      )
    end
  end

  def down
  end
end
