module StagesHelper
  def stage_text_color(hex)
    h = hex.to_s.delete("#")
    r, g, b = h.length == 3 ? h.chars.map { |c| (c*2).to_i(16) } : [h[0..1], h[2..3], h[4..5]].map { _1.to_i(16) }
    luminance = (0.2126*r + 0.7152*g + 0.0722*b) / 255.0
    luminance > 0.6 ? "#111111" : "#ffffff"
  rescue
    "#ffffff"
  end
end