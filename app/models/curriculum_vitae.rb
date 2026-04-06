class CurriculumVitae < ApplicationRecord
  self.table_name = "cv_contents"

  validates :content, presence: true

  def self.current
    first_or_initialize
  end
end
