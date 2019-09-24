module StepByStepFilter
  class Options
    def self.statuses(selected = nil)
      statuses = StepByStepPage::STATUSES.map do |status|
        {
          text: status.humanize,
          value: status,
          data_attributes: {
            show: status,
          },
          selected: selected.present? && selected == status,
        }
      end

      statuses.unshift(
        text: "All",
        data_attributes: {
          show: "all",
        },
        selected: selected.blank?,
      )
    end
  end
end
