= 12 Feb 2015
Tracking Shipment API:
- app/controllers/api/trackings_controller.rb
- config/routes.rb
- tracking.html
Show / Hide Columns on Shipment Trackings:
- app/models/shipment_trackings.rb
- app/views/shipment_trackings/_shipment_tracking.html.erb
- app/views/shipment_trackings/index.html.erb

= 13 Feb 2015
Yearly, Monthly, All on Control Center:
- app/models/constant.rb
- app/views/home/control_center.html.erb

= 23 Feb 2015
Monitorings
- app/assets/stylesheets/panel.css.scss
- app/assets/stylesheets/application.css.scss
- app/models/si_monitoring.rb
- app/models/bl_monitoring.rb
- app/models/cr_monitoring.rb
- app/models/commision_monitoring.rb
- app/controllers/application_controller.rb
- app/controllers/home_controller.rb
- app/controllers/sessions_controller.rb
- app/workers/*.rb
- app/views/home/index.html.erb
- app/views/commons/_home_panel.html.erb
- config/initializers/redis.rb
- config/sidekiq.yml
- db/migrate/20150204091346_create_si_monitorings.rb
- db/migrate/20150204103014_create_bl_monitorings.rb
- db/migrate/20150217063445_create_cr_monitorings.rb
- db/migrate/20150217073719_create_commision_monitorings.rb

= 12 Mar 2015
Revisi Bill of Lading
- db/migrate/20150312063826_add_hide_agent_to_bill_of_lading.rb
- app/controllers/bill_of_ladings_controller.rb
- app/views/bill_of_ladings/_form.html.erb
- app/views/bill_of_ladings/_bill_of_lading.html.erb
Ganti Phone Number
- app/views/invoices/_invoice.html.erb
- app/views/debit_notes/_debit_note.html.erb
- app/views/notes/_note.html.erb
