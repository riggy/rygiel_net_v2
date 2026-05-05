# frozen_string_literal: true

class AddVisitorName < ActiveRecord::Migration[8.1]
  def change
    add_column :trackguard_visitors, :name, :string
  end
end
