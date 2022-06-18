ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "asciicasts.com",  
  :user_name            => "apin4game@gmail.com",  
  :password             => "secretpassword",  
  :authentication       => "plain",  
  :enable_starttls_auto => true  
} 