class SlugValidator < ActiveModel::Validator
  def validate(record)
    # unless Services.publishing_api.lookup_content_id(base_path: "/#{record.slug}", with_drafts: true).nil?
    #   record.errors.add(:slug, "has already been taken.")
    # end
    true
  end
end
