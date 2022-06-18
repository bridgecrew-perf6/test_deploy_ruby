class TrackingMailer < ActionMailer::Base
  default from: "notification@noemail.com"

  def welcome_email
    mail(to: "apinrdw@gmail.com", subject: 'Welcome to My Awesome Site')
  end

  def tracking_confirm(type, email_address, tracking)
    @type = type
  	@tracking = Tracking.find(tracking)
  	bl_number = @tracking.bill_of_lading.master_bl_no.blank? ? @tracking.bill_of_lading.bl_number : @tracking.bill_of_lading.master_bl_no
    mail(to: email_address, subject: "Status Confirm for BL#: #{bl_number}")
  end

  def tracking_delay(type, email_address, tracking)
    @type = type
  	@tracking = Tracking.find(tracking)
  	bl_number = @tracking.bill_of_lading.master_bl_no.blank? ? @tracking.bill_of_lading.bl_number : @tracking.bill_of_lading.master_bl_no
    mail(to: email_address, subject: "Status Delay for BL#:  #{bl_number}")
  end

  def tracking_switch(type, email_address, tracking)
    @type = type
  	@tracking = Tracking.find(tracking)
  	bl_number = @tracking.bill_of_lading.master_bl_no.blank? ? @tracking.bill_of_lading.bl_number : @tracking.bill_of_lading.master_bl_no
    mail(to: email_address, subject: "Status Switch for BL#:  #{bl_number}")
  end
end
