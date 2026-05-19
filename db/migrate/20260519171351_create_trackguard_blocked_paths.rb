class CreateTrackguardBlockedPaths < ActiveRecord::Migration[8.1]
  def change
    create_table :trackguard_blocked_paths, if_not_exists: true do |t|
      t.string :pattern, null: false
      t.timestamps
    end

    add_index :trackguard_blocked_paths, :pattern, unique: true, if_not_exists: true
  end
end
