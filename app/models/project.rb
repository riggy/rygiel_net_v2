class Project < ApplicationRecord
  validates :name, presence: true

  scope :featured, -> { where(featured: true) }

  def tag_list
    tech_tags.to_s.split(",").map(&:strip).reject(&:empty?)
  end
end