class AddTrackingLayerToTrackguardVisits < ActiveRecord::Migration[8.1]
  def change
    add_column :trackguard_visits, :tracking_layer, :string
  end
end
