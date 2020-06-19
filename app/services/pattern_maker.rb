# frozen_string_literal: true

class PatternMaker
  PATTERNS = {
    starts_with: '^',
    nothing_else: '$',
    words: '\w[\w\s\.\,]+',
    perhaps_spaces: '\s*',
    anything: '.*'
  }.freeze

  WITHIN = {
    brackets: '()',
    sq_brackets: '[]'
  }.freeze

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
    pattern.join
  end

  def process_element(element)
    element
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

  def pattern_for(element)
    patterns.fetch(element.to_sym, element)
  end

  def target(element)
    element = remove_command(:target, element)
    "(#{process_element(element)})"
  end

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
    element.gsub! /^#{command}/, ''
    remove_outer(element)
  end
end
