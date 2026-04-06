class CurriculumVitaePresenter
  include MarkdownParser

  def initialize(curriculum_vitae)
    @curriculum_vitae = curriculum_vitae
  end

  def content
    markdown(@curriculum_vitae.content.to_s)
  end

  def updated_at
    return nil unless @curriculum_vitae.persisted?

    @curriculum_vitae.updated_at.strftime("%B %-d, %Y")
  end

  def present?
    @curriculum_vitae.persisted? && @curriculum_vitae.content.present?
  end

  def chatbot_context
    @curriculum_vitae.content
  end
end
