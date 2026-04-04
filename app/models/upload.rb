class Upload < ApplicationRecord
  has_one_attached :file

  validates :file, presence: true
  validate :acceptable_file

  def file_url
    Rails.application.routes.url_helpers.rails_storage_proxy_path(file, only_path: true)
  end

  private

  def acceptable_file
    return unless file.attached?

    unless file.content_type.in?(%w[image/png image/jpeg image/gif image/webp])
      errors.add(:file, "must be an image (PNG, JPEG, GIF, or WebP)")
    end

    if file.blob.byte_size > 5.megabytes
      errors.add(:file, "must be less than 5MB")
    end
  end
end
