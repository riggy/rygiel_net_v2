class RenameBlockedUserAgentsTable < ActiveRecord::Migration[8.1]
  def change
    rename_table :blocked_user_agents, :trackguard_blocked_user_agents
  end
end
