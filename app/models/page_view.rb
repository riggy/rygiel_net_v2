class PageView < ApplicationRecord
  validates :path, presence: true

  scope :today,      -> { where(created_at: Time.current.beginning_of_day..) }
  scope :this_week,  -> { where(created_at: 1.week.ago..) }
  scope :this_month, -> { where(created_at: 1.month.ago..) }
  scope :last_30,    -> { where(created_at: 30.days.ago..) }
end
