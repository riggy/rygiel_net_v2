json.totals do
  json.today   @total_today
  json.week    @total_week
  json.month   @total_month
end
json.top_pages @top_pages
json.top_referrers @top_referrers
json.recent @recent do |pv|
  json.path       pv.path
  json.ip         pv.visitor&.ip
  json.flagged    pv.visitor.flagged_at.present?
  json.user_agent pv.user_agent
  json.session_id pv.session_id
  json.trace_id   pv.trace_id
  json.referer    pv.referer
  json.created_at pv.created_at
end
