class ReferralLink < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9]([a-z0-9\-]*[a-z0-9])?\z/

  validates :slug,        presence: true, uniqueness: true,
                          format: { with: SLUG_FORMAT, message: "must be lowercase letters, digits, and hyphens" },
                          length: { maximum: 64 }
  validates :name,        presence: true, length: { maximum: 100 }
  validates :target_path, presence: true, format: { with: %r{\A/[^\s]*\z}, message: "must start with / and contain no spaces" }
  validates :clicks,      numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def destination_url
    uri = URI.parse(target_path)
    params = URI.decode_www_form(uri.query.to_s).to_h
    params["ref"] = slug
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
