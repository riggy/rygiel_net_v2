class WhitelistedIp < ApplicationRecord
  validates :ip, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(expires_at: Time.current..) }

  def self.whitelisted?(ip)
    active.exists?(ip: ip)
  end
end
