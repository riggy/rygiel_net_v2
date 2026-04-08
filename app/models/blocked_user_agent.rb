class BlockedUserAgent < ApplicationRecord
  validates :pattern, presence: true, uniqueness: true
end
