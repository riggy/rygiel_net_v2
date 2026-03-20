module MarkdownParser
  include ActionView::Helpers::SanitizeHelper
  extend ActiveSupport::Concern

  included do
    def markdown(text)
      text_with_emoji = (text || "").gsub(/:(\w+):/) do |match|
        emoji = Emoji.find_by_alias($1)
        emoji ? emoji.raw : match
      end


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
      sanitize(md.render(text_with_emoji || ""))
    end
  end
end
