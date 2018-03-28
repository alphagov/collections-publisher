class PublishIntent
  include ActiveModel::Validations

  attr_accessor :update_type, :change_note

  validates :update_type, presence: true, inclusion: { in: %w(major minor), message: "%<value> must be either major or minor" }
  validates :change_note, presence: true, if: :major_update?

  def self.minor_update
    new(update_type: "minor")
  end

  def initialize(params)
    @update_type = params[:update_type]
    @change_note = params[:change_note]
  end

  def major_update?
    update_type == "major"
  end

  def present
    {
      update_type: update_type,
      change_note: change_note || ""
    }
  end
end
