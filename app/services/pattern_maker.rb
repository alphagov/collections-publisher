# frozen_string_literal: true

# Service to allow Regular Expressions to be defined with human readable syntax
class PatternMaker
  PATTERNS = {
    starts_with: "^",
    nothing_else: "$",
    words: '\w[\w\s\.\,]+',
    perhaps_spaces: '\s*',
    anything: ".*",
  }.freeze

  WITHIN = {
    brackets: "()",
    sq_brackets: "[]",
  }.freeze

  # Example usage:
  #
  #   PatternMaker.call "starts_with x then perhaps_spaces and y", x: '[xX]', y: '[yY]'
  #
  # outputs -> /^[xX]\s*[yY]/
  def self.call(*args)
    new(*args).pattern
  end

  attr_reader :description, :patterns

  def initialize(description, patterns = {})
    @description = description
    @patterns = PATTERNS.merge(patterns)
  end

  def elements
    description.split(/\s/)
  end

  def pattern
    pattern = elements.map { |e| process_element(e) }
    pattern.compact!
    /#{pattern.join}/.freeze
  end

  def process_element(element)
    case element
    when /^target\(/
      target(element)
    when /^within\(/
      within(element)
    when /^\'.*\'$/
      remove_outer(element)
    when /(then|and)/
      # ignore
    else
      pattern_for(element)
    end
  end

  # Matches the element to patterns defined within patterns
  # If a pattern is found, replaces the element with the pattern
  # If no pattern is found, inserts the element as is, into the output regular expression
  def pattern_for(element)
    patterns.fetch(element.to_sym, element)
  end

  # Identifies an element as a key piece of text that can be extracted from a match
  # The target elements will populate `named_captures` with:
  #   the element as the key
  #   and the matching substring as the value
  #
  # Usage:
  #
  #     "target(foo)"
  #
  #   Will add an element foo, and add "foo" to named_captures
  #
  def target(element)
    element = remove_command(:target, element)
    "(?<#{element}>#{process_element(element)})"
  end

  # Used to place an element within matching escaped braces (defined in WITHIN)
  #
  # Usage:
  #
  #    "within(brackets,foo)
  #
  #  Will create "\(foo\)"
  #
  def within(element)
    element = remove_command(:within, element)
    type, pattern = element.split(/\,/, 2)
    start, finish = WITHIN[type.to_sym].chars
    [escaped(start), process_element(pattern), escaped(finish)].join
  end

  def escaped(element)
    "\\#{element}"
  end

  def remove_outer(element)
    element[1..-2]
  end

  def remove_command(command, element)
    element.gsub!(/^#{command}/, "")
    remove_outer(element)
  end
end
