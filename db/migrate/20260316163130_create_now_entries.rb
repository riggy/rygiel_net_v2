class CreateNowEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :now_entries do |t|
      t.text :working_on
      t.string :reading
      t.string :learning

      t.timestamps
    end
  end
end
