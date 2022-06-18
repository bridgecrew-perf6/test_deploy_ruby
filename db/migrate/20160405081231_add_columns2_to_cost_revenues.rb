class AddColumns2ToCostRevenues < ActiveRecord::Migration
  def change
    add_column :cost_revenues, :master_bl_no, :string
	
	add_column :cost_revenues, :shipper_reference, :string
    add_column :cost_revenues, :carrier, :string    
    # add_column :cost_revenues, :shipper_id, :string
    # add_column :cost_revenues, :consignee_id, :string
    add_reference :cost_revenues, :shipper, index: true
    add_reference :cost_revenues, :consignee, index: true
    add_column :cost_revenues, :trade, :string
    
    add_column :cost_revenues, :first_vessel_name, :string
    add_column :cost_revenues, :first_etd_date, :date
    add_column :cost_revenues, :port_of_loading, :string
    add_column :cost_revenues, :port_of_discharge, :string
    add_column :cost_revenues, :final_destination, :string
    add_column :cost_revenues, :volume, :string

  end
end
