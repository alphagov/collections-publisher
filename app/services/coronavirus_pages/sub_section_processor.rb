module CoronavirusPages
  class SubSectionProcessor
    def self.call(*args)
      new(*args).output
    end

    attr_reader :sub_sections

    def initialize(sub_sections)
      @sub_sections = [sub_sections].flatten
    end

    def output
      process
      output_array.join("\n")
    end

    def output_array
      @output_array ||= []
    end

    def add_string(text)
      output_array << text
    end

    def process
      sub_sections.each do |sub_section|
        add_string("####{sub_section[:title]}") if sub_section[:title].present?
        sub_section[:list].each do |item|
          add_string "[#{item[:label]}](#{item[:url]})"
        end
      end
    end
  end
end
