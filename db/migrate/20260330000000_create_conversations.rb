class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.integer  :visitor_id
      t.string   :session_id
      t.string   :ip, null: false
      t.datetime :last_activity_at, null: false
      t.timestamps
    end

    add_index :conversations, :visitor_id
    add_index :conversations, :last_activity_at
    add_foreign_key :conversations, :visitors
  end
end
