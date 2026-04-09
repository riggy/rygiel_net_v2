class Conversation < ApplicationRecord
  belongs_to :visitor, class_name: "Trackguard::Visitor", optional: true
  has_many :messages, -> { order(:created_at) }, dependent: :destroy

  validates :ip, :last_activity_at, presence: true

  before_validation :set_last_activity_at, on: :create

  scope :recent, -> { order(last_activity_at: :desc) }

  def channel_name
    "conversation_#{id}"
  end

  private

  def set_last_activity_at
    self.last_activity_at ||= Time.current
  end
end
