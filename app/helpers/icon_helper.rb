module IconHelper
  ALIASES = {
    curated: 'list-alt',
    a_to_z: 'sort-by-alphabet',
    add: 'plus',
  }.freeze

  def icon(name)
    return unless name

    class_name = ALIASES[name.to_sym] || name
    content_tag :i, '',
      class: "glyphicon glyphicon-#{class_name}",
      data: { toggle: 'tooltip' },
      title: name.to_s.humanize
  end
end
