class TriggerErrorController < ApplicationController
  def now
    raise StandardError.new("Custom exception from Chris - with backtrace cleaned & custom silencer")
  end
end
