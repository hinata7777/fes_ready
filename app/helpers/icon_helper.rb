module IconHelper
  def icon(name, class_name: "h-7 w-7", **opts)
    inline_svg_tag("icons/#{name}.svg",
      class: class_name,
      aria: { hidden: true },
      focusable: false,
      **opts
    )
  end
end
