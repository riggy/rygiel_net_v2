namespace :analytics do
  desc "Delete PageView records older than 90 days"
  task cleanup: :environment do
    deleted = PageView.where("created_at < ?", 90.days.ago).delete_all
    puts "Deleted #{deleted} page view records older than 90 days."
  end
end
