class Project < ApplicationRecord
  validates :name, presence: true

  scope :featured, -> { where(featured: true) }
  scope :positioned, -> { order(position: :asc) }

  before_create :set_default_position

  def tag_list
    tech_tags.to_s.split(",").map(&:strip).reject(&:empty?)
  end

  private

  def set_default_position
    self.position = (Project.maximum(:position) || -1) + 1
  end
end
