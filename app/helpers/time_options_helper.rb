# frozen_string_literal: true

module TimeOptionsHelper
  def time_options
    %w[am pm].flat_map do |period|
      hours = [12] + (1..11).to_a
      hours.flat_map do |hour|
        next ["12:01am", "12:30am"] if hour == 12 && period == "am"

        ["#{hour}:00#{period}", "#{hour}:30#{period}"]
      end
    end
  end

  def format_time_12_hour_clock(datetime)
    datetime.strftime("%-l:%M%P")
  end

  def format_full_date_and_time(datetime)
    datetime.strftime("%-l:%M%P on %-d %B %Y")
  end

  def format_full_date(datetime)
    datetime.strftime("%-d %B %Y")
  end

  def default_datetime_placeholder(
    year: 1.day.from_now.year,
    month: 1.day.from_now.month,
    day: 1.day.from_now.day,
    time: format_time_12_hour_clock(1.day.from_now.change(hour: 9))
  )
    {
      year:,
      month:,
      day:,
      time:,
    }
  end
end
