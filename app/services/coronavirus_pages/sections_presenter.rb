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
      {
        title: hash[:title],
        content: SubSectionProcessor.call(hash[:sub_sections]),
      }
    end
  end
end
