class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.integer :conversation_id, null: false
      t.string  :role,            null: false
      t.text    :content,         null: false
      t.timestamps
    end

    add_index :messages, [ :conversation_id, :created_at ]
    add_foreign_key :messages, :conversations
  end
end
