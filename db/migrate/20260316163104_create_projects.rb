class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :tech_tags
      t.string :url
      t.boolean :featured

      t.timestamps
    end
  end
end
