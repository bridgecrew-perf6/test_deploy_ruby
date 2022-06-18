class AddColumnsToMonitorings < ActiveRecord::Migration
  def change
    add_column :si_monitorings, :name, :string
    add_column :si_monitorings, :ibl_ref, :string
    add_column :si_monitorings, :etd_date, :date

    add_column :document_monitorings, :name, :string
    # add_column :document_monitorings, :ibl_ref, :string
    # add_column :document_monitorings, :etd_date, :date

    add_column :bl_monitorings, :name, :string
    add_column :bl_monitorings, :ibl_ref, :string
    add_column :bl_monitorings, :etd_date, :date
    add_reference :bl_monitorings, :shipping_instruction, index: true

    add_column :payment_monitorings, :name, :string
    add_column :payment_monitorings, :ibl_ref, :string
    add_column :payment_monitorings, :etd_date, :date

    add_column :cr_monitorings, :name, :string
    add_column :cr_monitorings, :ibl_ref, :string
    add_column :cr_monitorings, :etd_date, :date

    add_column :shipment_monitorings, :name, :string
    add_column :shipment_monitorings, :ibl_ref, :string
    add_column :shipment_monitorings, :etd_date, :date

    add_column :invoice_monitorings, :name, :string
    # add_column :invoice_monitorings, :ibl_ref, :string
    # add_column :invoice_monitorings, :etd_date, :date

    add_column :sell_cost_monitorings, :name, :string
    # add_column :sell_cost_monitorings, :ibl_ref, :string
    # add_column :sell_cost_monitorings, :etd_date, :date
  end
end
