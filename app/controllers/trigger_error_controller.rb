class TriggerErrorController < ApplicationController
  def now
    raise StandardError.new("Custom exception from Chris #1")
  end

  def then
    raise StandardError.new("Custom exception from Chris #2")
  end
end
