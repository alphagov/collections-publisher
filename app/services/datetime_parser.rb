# frozen_string_literal: true

class DatetimeParser
  def initialize(date:, time:)
    @raw_date = date.to_h
    @raw_time = time.to_s
  end

  def parse
    begin
      check_date_is_valid
      check_time_is_valid

      Time.find_zone("London").local(
        raw_date[:year].to_i,
        raw_date[:month].to_i,
        raw_date[:day].to_i,
        time[:hour],
        time[:minute]
      )
    rescue ArgumentError
      nil
    end
  end

private

  attr_reader :raw_date, :raw_time

  def check_date_is_valid
    day, month, year = raw_date.values_at(:day, :month, :year)
    Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
  end

  def check_time_is_valid
    raise ArgumentError unless parsed_time_values
  end

  def parsed_time_values
    @parsed_time_values ||= raw_time.match(%r{
      \A
      (?<hour>(2[0-3]|1[0-9]|0?[0-9]))
      :
      (?<minute>[0-5][0-9])
      (\s?(?<period>(am|pm)))?
      \Z
    }ix)
  end

  def time
    @time ||= begin
      hour = parsed_time_values[:hour].to_i
      period = parsed_time_values[:period]&.downcase
      minute = parsed_time_values[:minute].to_i

      if period == "am" && hour == 12
        hour = 0
      elsif period == "pm" && hour < 12
        hour += 12
      end

      { hour: hour, minute: minute }
    end
  end
end
