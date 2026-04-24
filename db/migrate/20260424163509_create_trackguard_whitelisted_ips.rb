class CreateTrackguardWhitelistedIps < ActiveRecord::Migration[8.1]
  def change
    rename_table :whitelisted_ips, :trackguard_whitelisted_ips
  end
end
