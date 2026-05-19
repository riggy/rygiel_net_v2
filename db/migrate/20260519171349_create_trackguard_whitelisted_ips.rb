class CreateTrackguardWhitelistedIps < ActiveRecord::Migration[8.1]
  def change
    create_table :trackguard_whitelisted_ips, if_not_exists: true do |t|
      t.string   :ip,         null: false
      t.datetime :expires_at, null: false
      t.references :visitor,  foreign_key: { to_table: :trackguard_visitors }
      t.timestamps
    end

    add_index :trackguard_whitelisted_ips, :ip,         unique: true, if_not_exists: true
    add_index :trackguard_whitelisted_ips, :expires_at, if_not_exists: true
  end
end
