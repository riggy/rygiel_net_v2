class AddVisitorToWhitelistedIps < ActiveRecord::Migration[8.1]
  def change
    add_reference :whitelisted_ips, :visitor, null: true, foreign_key: true, index: true
  end
end
