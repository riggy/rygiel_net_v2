class Visitor < ApplicationRecord
  has_many :page_views
  has_one :whitelisted_ip

  scope :unflagged, -> { where(flagged_at: nil) }
  scope :flagged, -> { where.not(flagged_at: nil) }
end
