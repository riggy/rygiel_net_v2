class RenameTrackingTablesToTrackguard < ActiveRecord::Migration[8.1]
  def change
    rename_table :visitors,   :trackguard_visitors
    rename_table :page_views, :trackguard_page_views
  end
end
