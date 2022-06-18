class PaymentServices
  def initialize(payment)
    @payment = payment
  end

  def cancel!
    @payment.update_attribute(:is_cancel, true)
  end

  def uncancel!
    @payment.update_attribute(:is_cancel, false)
  end

  def update_status!(status)
    @payment.update_attribute(:status, status)
  end
end