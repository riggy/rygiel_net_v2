class CreateTrackguardBlockedUserAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :trackguard_blocked_user_agents, if_not_exists: true do |t|
      t.string :pattern, null: false
      t.timestamps
    end

    add_index :trackguard_blocked_user_agents, :pattern, unique: true, if_not_exists: true
  end
end
