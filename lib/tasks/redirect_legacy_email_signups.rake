desc "Redirect legacy email signups"
task redirect_legacy_email_signups: :environment do
  # Exclude parent specialist sectors as they never included an email signup option
  specialist_sector_slugs = Topic.where(state: "published").where.not(parent_id: nil).map(&:full_slug)

  specialist_sector_slugs.each do |slug|
    base_path = "/topic/#{slug}/email-signup"
    destination = "/topic/#{slug}"

    redirect = {
      base_path: base_path,
      document_type: "redirect",
      schema_name: "redirect",
      publishing_app: "collections-publisher",
      update_type: "major",
      redirects: [
        { path: base_path, type: "exact", destination: destination },
      ],
    }

    content_id = SecureRandom.uuid
    Services.publishing_api.put_content(content_id, redirect)
    Services.publishing_api.publish(content_id)

    puts "Redirected #{base_path} to #{destination}"
  end
end
