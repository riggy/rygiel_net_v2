class CreateReferralLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :referral_links do |t|
      t.string  :slug,        null: false
      t.string  :name,        null: false
      t.string  :target_path, null: false
      t.integer :clicks,      null: false, default: 0
      t.boolean :active,      null: false, default: true
      t.timestamps
    end

    add_index :referral_links, :slug, unique: true
    add_index :referral_links, :active
  end
end
