class ShipmentMonitoring < ActiveRecord::Base # Outstanding Shipment
  belongs_to :shipping_instruction
  has_one :shipment_tracking, through: :shipping_instruction

  # def actual_name
  #   # "#{hbl_no} / #{mbl_no}"
  #   self.name
  # end

  def shipment_tracking_id
    self.shipment_tracking.try(:id)
  end
end
