class NowEntry < ApplicationRecord
  validates :content, presence: true
end
