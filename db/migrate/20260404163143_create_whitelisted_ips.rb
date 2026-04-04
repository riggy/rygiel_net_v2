class CreateWhitelistedIps < ActiveRecord::Migration[8.1]
  def change
    create_table :whitelisted_ips do |t|
      t.string :ip, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :whitelisted_ips, :ip, unique: true
    add_index :whitelisted_ips, :expires_at
  end
end
