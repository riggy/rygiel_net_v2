class Post < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where(published: true).order(published_at: :desc) }

  before_save :set_published_at

  private

  def set_published_at
    self.published_at ||= Time.current if published?
  end
end
