module CoronavirusPages
  class SectionsPresenter
    attr_reader :data
    def initialize(data)
      @data = [data].flatten
    end

    def output
      data.map do |section|
        converter(section)
      end
    end

    def converter(hash)
      sub_section_data = SubSectionProcessor.call(hash["sub_sections"])

      {
        "title": hash["title"],
        "content": sub_section_data[:content],
        "featured_link": sub_section_data[:featured_link],
      }
    end
  end
end
