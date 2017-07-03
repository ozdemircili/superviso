MKD_SAFE_RENDERER = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML.new(:filter_html => true, :hard_wrap => true),
  :no_intra_emphasis => true,
  :autolink => true
)

MKD_RENDERER = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML.new,
  :no_intra_emphasis => true,
  :autolink => true
)
