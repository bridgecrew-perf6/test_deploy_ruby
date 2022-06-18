class DetailShipmentReport
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :format, :ibl_ref

  validates_presence_of :format, :ibl_ref
  validates_inclusion_of :format, in: ["pdf", "xls"]

  def filename
    tmp = "Detail Shipment #{self.ibl_ref}"
    tmp.upcase
  end

  def title
    tmp = "Detail Shipment"
    tmp.upcase
  end

  def populate_data
    data = ShippingInstruction.includes(:author, :shipper, :consignee, {si_containers: [:container]}, {shipment_tracking: [{actual_vessels: [:vessel]}]}, {bill_of_lading: [:invoices, :debit_notes, :notes]})
    .where(si_no: self.ibl_ref).references(:author, :shipper, :consignee, {si_containers: [:container]}, {shipment_tracking: [{actual_vessels: [:vessel]}]}, {bill_of_lading: [:invoices, :debit_notes, :notes]}).first
    data
  end

  def template
    "detail_shipment_report"
  end
end
