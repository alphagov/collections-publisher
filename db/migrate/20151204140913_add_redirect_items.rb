class AddRedirectItems < ActiveRecord::Migration
  def up
    RedirectItem.delete_all

    Tag.includes(:redirect_routes).each do |tag|
      tag.redirect_routes.each do |route|
        next if route.from_base_path.starts_with?(tag.base_path) || route.from_base_path == tag.base_path

        RedirectItem.create!(
          content_id: SecureRandom.uuid,
          from_base_path: route.from_base_path,
          to_base_path: route.to_base_path,
          related_tag: tag,
        )

        route.destroy!
      end
    end
  end

  def down
    RedirectItem.all.each do |redirect_item|
      RedirectRoute.create!(
        tag: redirect_item.related_tag,
        from_base_path: redirect_item.from_base_path,
        to_base_path: redirect_item.to_base_path,
      )
    end
  end
end
