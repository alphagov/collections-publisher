module ErrorItemsHelper
  def error_items(error_messages, field)
    if error_messages.key?(field)
      error_messages[field].map { |message| "#{field.to_s.titleize} #{message}".capitalize }.join("\n")
    end
  end
end
