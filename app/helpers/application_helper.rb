module ApplicationHelper
  def website_url(base_path)
    Plek.website_root + base_path
  end

  def content_tagger_url
    Plek.external_url_for("content-tagger")
  end

  def draft_govuk_url(path)
    Plek.find("draft-origin", external: true) + path
  end

  def step_by_step_preview_url(step_by_step_page)
    payload = {
      "sub" => step_by_step_page.auth_bypass_id,
      "iat" => Time.zone.now.to_i,
      "exp" => 1.month.from_now.to_i,
      "draft_asset_manager_access" => true,
      "content_id" => step_by_step_page.content_id,
    }
    token = JWT.encode(payload, ENV["JWT_AUTH_SECRET"], "HS256")
    "#{draft_govuk_url("/#{step_by_step_page.slug}")}?token=#{token}"
  end

  def published_url(slug)
    "#{Plek.website_root}/#{slug}"
  end

  def markdown_to_html(markdown)
    sanitize(Kramdown::Document.new(markdown).to_html)
  end

  def render_markdown(content)
    render "govuk_publishing_components/components/govspeak" do
      markdown_to_html(content)
    end
  end
end
