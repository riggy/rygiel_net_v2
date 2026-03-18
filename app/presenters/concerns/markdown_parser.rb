module MarkdownParser
  include ActionView::Helpers::SanitizeHelper
  extend ActiveSupport::Concern

  included do
    def markdown(text)
      renderer = Redcarpet::Render::HTML.new(
        filter_html: true,
        safe_links_only: true,
        hard_wrap: true,
        link_attributes: { target: "_blank", rel: "noopener noreferrer" }
      )
      md = Redcarpet::Markdown.new(renderer,
                                   autolink: true,
                                   tables: true,
                                   fenced_code_blocks: true,
                                   strikethrough: true,
                                   superscript: true
      )
      sanitize(md.render(text || ""))
    end
  end
end