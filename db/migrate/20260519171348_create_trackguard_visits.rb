class CreateTrackguardVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :trackguard_visits, if_not_exists: true do |t|
      t.string    :type
      t.string    :path,         null: false
      t.string    :user_agent
      t.string    :referer
      t.string    :session_id
      t.string    :trace_id
      t.string    :source
      t.string    :block_reason
      t.string    :http_method
      t.references :visitor,     null: false, foreign_key: { to_table: :trackguard_visitors }
      t.datetime :created_at,   null: false
    end

    add_index :trackguard_visits, :type,         if_not_exists: true
    add_index :trackguard_visits, :path,         if_not_exists: true
    add_index :trackguard_visits, :created_at,   if_not_exists: true
    add_index :trackguard_visits, :source,       if_not_exists: true
    add_index :trackguard_visits, :block_reason, if_not_exists: true
  end
end
