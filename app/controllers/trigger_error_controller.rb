class TriggerErrorController < ApplicationController
  def now
    raise StandardError.new("Custom exception from Chris")
  end
end
