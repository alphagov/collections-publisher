class SlugValidator < ActiveModel::Validator
  def validate(record)
    unless Services.publishing_api.lookup_content_id(base_path: "/#{record.slug}" , with_drafts: true).nil?
      record.errors[:slug] << "Slug has already been taken."
    end
  end
end
