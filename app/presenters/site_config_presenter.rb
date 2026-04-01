class SiteConfigPresenter
  include MarkdownParser

  def initialize(site_config)
    @site_config = site_config
  end

  def hero_tagline
    # we might have some markup here
    @site_config["hero_tagline"].html_safe
  end

  def hero_description
    @site_config["hero_description"]
  end

  def about_text
    markdown(@site_config["about_text"])
  end

  def profile_photo_path
    return if @site_config["profile_photo_path"].blank?

    return unless File.exist?(Rails.root.join("public", "images", @site_config["profile_photo_path"]).to_s)

    [ "/images", @site_config["profile_photo_path"] ].join("/")
  end

  def profile_photo_alt
    return if profile_photo_path.blank?

    File.basename(profile_photo_path).split(".")[0]&.titleize
  end

  def skills
    @site_config["skills"].to_s.split(",").map(&:strip)
  end

  def contact
    @site_config["contact"]
  end

  def contact_email
    @site_config["contact_email"]
  end

  def contact_linkedin
    @site_config["contact_linkedin"]
  end

  def contact_github
    @site_config["contact_github"]
  end

  def chatbot_context
    sections = []
    sections << "About: #{@site_config['about_text']}" if @site_config["about_text"].present?
    sections << "Skills: #{@site_config['skills']}" if @site_config["skills"].present?
    sections << "Contact: #{@site_config['contact_email']}" if @site_config["contact_email"].present?
    sections << "GitHub: #{@site_config['contact_github']}" if @site_config["contact_github"].present?
    sections << "LinkedIn: #{@site_config['contact_linkedin']}" if @site_config["contact_linkedin"].present?
    sections.join("\n")
  end
end
