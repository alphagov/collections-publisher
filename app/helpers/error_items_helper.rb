module ErrorItemsHelper
  def error_items(error_messages, field)
    if error_messages.key?(field)
      error_messages[field].map { |message| "#{field.to_s.titleize} #{message}".capitalize }.join("\n")
    end
  end

  def issues_for(object, attribute)
    object.errors.errors.filter_map do |error|
      if error.attribute == attribute
        {
          text: error.options[:message],
        }
      end
    end
  end
end
