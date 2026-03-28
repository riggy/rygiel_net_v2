class DetectSuspiciousVisitorsJob < ApplicationJob
  queue_as :default

  HARD_FLAG_THRESHOLD  = 50
  HIGH_VOLUME_MIN      = 20
  MEDIUM_VOLUME_MIN    = 10
  FLAG_SCORE_THRESHOLD = 6
  MIN_VIEWS            = 3

  WEIGHTS = {
    high_volume:   4,
    medium_volume: 2,
    no_session:    3,
    no_referer:    2
  }.freeze

  def perform
    recent_cutoff = 24.hours.ago

    visitor_ids = PageView
      .where(created_at: recent_cutoff..)
      .where.not(visitor_id: nil)
      .distinct
      .pluck(:visitor_id)

    return if visitor_ids.empty?

    visitors = Visitor.unflagged.where(id: visitor_ids).index_by(&:id)
    return if visitors.empty?

    views_by_visitor = PageView
      .where(visitor_id: visitors.keys, created_at: recent_cutoff..)
      .select(:visitor_id, :session_id, :referer, :path)
      .group_by(&:visitor_id)

    visitors.each_value do |visitor|
      analyze_visitor(visitor, views_by_visitor[visitor.id] || [])
    end
  end

  private

  def analyze_visitor(visitor, views)
    count = views.size
    return if count.zero?

    if count >= HARD_FLAG_THRESHOLD
      flag!(visitor, "#{count} page views in 24h (hard flag threshold)")
      return
    end

    # Don't flag casual visitors with very few views — on a single-page site,
    # legitimate users naturally hit only "/" once or twice.
    return if count < MIN_VIEWS

    score   = 0
    reasons = []

    if count >= HIGH_VOLUME_MIN
      score += WEIGHTS[:high_volume]
      reasons << "#{count} page views in 24h"
    elsif count >= MEDIUM_VOLUME_MIN
      score += WEIGHTS[:medium_volume]
      reasons << "#{count} page views in 24h"
    end

    if blank_ratio(views, :session_id) > 0.8
      score += WEIGHTS[:no_session]
      reasons << "#{pct(views, :session_id)}% of views had no session"
    end

    if blank_ratio(views, :referer) > 0.0
      score += WEIGHTS[:no_referer]
      reasons << "#{pct(views, :referer)}% of views had no referer"
    end

    return if score < FLAG_SCORE_THRESHOLD

    flag!(visitor, reasons.join("; "))
  end

  def flag!(visitor, reason)
    visitor.update!(flagged_at: Time.current, flag_reason: reason, flagged_by: "DetectSuspiciousVisitorsJob")
  end

  def blank_ratio(views, attr)
    views.count { |v| v.public_send(attr).blank? }.to_f / views.size
  end

  def pct(views, attr)
    (blank_ratio(views, attr) * 100).round
  end
end
