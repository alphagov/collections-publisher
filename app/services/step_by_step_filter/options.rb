module StepByStepFilter
  class Options
    def self.statuses
      statuses = StepByStepPage::STATUSES.map do |status|
        {
          text: status.humanize,
          value: status,
          data_attributes: {
            show: status
          },
        }
      end

      statuses.unshift(
        text: "All",
        data_attributes: {
          show: "all"
        },
      )
    end
  end
end
