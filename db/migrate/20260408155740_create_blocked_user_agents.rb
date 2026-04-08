class CreateBlockedUserAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :blocked_user_agents do |t|
      t.string :pattern, null: false

      t.timestamps
    end

    add_index :blocked_user_agents, :pattern, unique: true
  end
end
