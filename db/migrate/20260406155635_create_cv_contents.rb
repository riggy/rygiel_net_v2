class CreateCvContents < ActiveRecord::Migration[8.1]
  def change
    create_table :cv_contents do |t|
      t.text :content

      t.timestamps
    end
  end
end
