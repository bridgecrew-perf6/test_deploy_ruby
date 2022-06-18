class ShipmentTracking < ActiveRecord::Base
  default_value_for :notes, value: "No Status", allows_nil: false

  belongs_to :shipping_instruction, touch: true
  has_many :actual_vessels, :dependent => :destroy
  accepts_nested_attributes_for :actual_vessels

  scope :recent, -> {
    # includes({shipping_instruction: [:shipper, {vessels: [:actual_vessel]}]}, {actual_vessels: [:vessel]})
    # .references({shipping_instruction: [:shipper, {vessels: [:actual_vessel]}]}, {actual_vessels: [:vessel]})
  }

  after_commit :generate_workers

  search_syntax do
    search_by :text do |scope, phrases|
      columns = [:notes, "shipping_instructions.si_no", "shippers.company_name", "shipping_instructions.carrier"]
      scope.where_like(columns => phrases)
    end
  end

  # STATUS FREE TIME
  REQUEST = 0
  APPROVED = 1
  NO_FT = 2

  %w(REQUEST APPROVED NO_FT).each do |state|
    define_method "#{state.downcase}?" do
      free_status == self.class.const_get(state)
    end
  end

  def status_free_time
    if self.request?
      "Request"
    elsif self.approved?
      return "Approved"
    elsif self.no_ft?
      return "No Request"
    end
  end

  def self.with_filter(params)
    # # shipments = ShipmentTracking.includes(shipping_instruction: [ :shipper, :vessels ]).recent
    # shipments = ShipmentTracking.includes(shipping_instruction: [ :shipper, :vessels ])
    # shipments = shipments.search(params[:query]) unless params[:query].to_s.empty?
    # shipments = shipments.where(free_status: params[:free_status]) unless params[:free_status].to_s.empty?
    # # Revisi 1 Dec 2015
    # begin
    #   shipments = shipments.where(fu_date: Date.parse(params[:fu_date])) unless params[:fu_date].to_s.empty?
    # rescue
    # end
    
    # begin
    #   date = Date.parse(params[:query])
    #   shipments = shipments.or.where("vessels.etd_date = ? OR vessels.eta_date = ?", date, date)
    # rescue
    #   # ignored
    # end

    shipments = ShipmentTracking.includes(:shipping_instruction)
    year = params[:year].presence || Date.today.year
    if year.to_i > 0
      shipments = shipments.where("shipping_instructions.si_no LIKE :si_no", si_no: "IBL#{year.to_s[2..3]}%").references(:shipping_instruction)
    end

    # shipments#.page(params[:page])
    if Rails.env.development?
      shipments.last(10)
    else
      shipments
    end
  end

  def self.edit_row(id)
    shipment = ShipmentTracking.includes(shipping_instruction: [:shipper, :vessels])
                .references(shipping_instruction: [:shipper, :vessels]).where(id: id).first
    shipment.shipping_instruction.vessels.each do |vessel|
      shipment.actual_vessels.find_or_create_by(vessel: vessel)
    end

    shipment
  end

  def port_of_loading
    si = self.shipping_instruction
    unless si.blank?
      unless si.bill_of_lading.blank?
        si.bill_of_lading.port_of_loading
      else
        si.port_of_loading
      end
    end
  end

  def ibl_ref_with_status
    str = self.shipping_instruction.ibl_ref
    str += " (Cancel)" if self.shipping_instruction.is_canceled?
    str += " (Connecting!)" if self.shipping_instruction.is_connecting?
    str += " (Arrived!)" if self.shipping_instruction.is_arrived?
    str
  end

  private
  def generate_workers
    ShipmentMonitoringWorker.perform_async(shipping_instruction_id)
  end
end
