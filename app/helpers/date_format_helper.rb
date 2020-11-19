module DateFormatHelper
  def format_published_at(day, month, year)
    if date_fields_present?(day, month, year)
      begin
        format_date(day, month, year)
      rescue ArgumentError, RangeError => e
        Rails.logger.info "Rescued: #{e.inspect}"
        nil
      end
    end
  end

private

  def date_fields_present?(day, month, year)
    day.present? && month.present? && year.present?
  end

  def format_date(day, month, year)
    { published_at: Time.zone.local(
      year,
      month,
      day,
    ) }
  end
end
