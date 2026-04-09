class PurgeStaleTrackingDataJob < ApplicationJob
  queue_as :default

  RETENTION_DAYS = 90

  def perform
    cutoff = RETENTION_DAYS.days.ago

    Trackguard::PageView.where(created_at: ..cutoff).delete_all

    stale_visitor_ids = Trackguard::Visitor
                          .where(last_seen_at: ..cutoff)
                          .where.not(
                            id: Trackguard::PageView.select(:visitor_id)
                          )
                          .ids

    return if stale_visitor_ids.empty?

    WhitelistedIp.where(visitor_id: stale_visitor_ids).update_all(visitor_id: nil)
    Conversation.where(visitor_id: stale_visitor_ids).update_all(visitor_id: nil)
    Trackguard::Visitor.where(id: stale_visitor_ids).delete_all
  end
end
