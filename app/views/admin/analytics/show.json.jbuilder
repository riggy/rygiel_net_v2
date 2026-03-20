json.totals do
  json.today   @total_today
  json.week    @total_week
  json.month   @total_month
end
json.top_pages @top_pages
json.top_referrers @top_referrers
json.recent @recent, :path, :ip, :referer, :created_at
