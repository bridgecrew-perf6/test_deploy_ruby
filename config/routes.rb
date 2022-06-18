require 'sidekiq/web'

Rails.application.routes.draw do
  get "reports/index"
  
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :vessels
  resources :payments do
    member do
      # match 'update_status', path: 'update-status', via: [:put, :patch]
      get 'cancel'
      get 'uncancel'
      get 'email'
    end
    collection do
      # get 'plan'
      # get 'inquiry'
      # get 'tax'
      # get 'deposit'
      # get 'report'

      post 'update_tax'
      get 'calculate_invoice'
      get 'view_calculate_invoice'
      match 'update_calculate_invoice', via: [:put, :patch]
      post 'report'
    end
  end
  
  resources :debit_notes do
    collection do
      post 'paid'
      post 'unpaid'
      post 'update_tax'
    end
    member do
      get 'cancel'
      get 'uncancel'
      match 'update_status', path: 'update-status', via: [:put, :patch]
    end
  end
  resources :notes do
    collection do
      post 'paid'
      post 'unpaid'
      post 'update_tax'
    end
    member do
      get 'cancel'
      get 'uncancel'
      match 'update_status', path: 'update-status', via: [:put, :patch]
    end
  end
  resources :invoices do
    collection do
      # get 'controlCenter'
      # get 'outstandingBonShipment'
      # match 'searchInvoices', via: :all
      # match 'searchBonShipment', via: :all
      post 'paid'
      post 'unpaid'
      post 'update_tax'
      post 'report'
    end
    member do
      get 'cancel'
      get 'uncancel'
      match 'update_status', path: 'update-status', via: [:put, :patch]
    end
  end
  resources :bill_of_ladings do
    member do
      get 'print'
      get 'history'
      get 'cancel'
      get 'uncancel'
      # Revisi 1 Dec 2015
      get 'not_yet', as: 'not_yet_delivery_doc'
      get 'done', as: 'done_delivery_doc'
    end
    collection do
      # get 'update_delivery_doc', path: 'update-delivery-doc'
      get 'new_part_bl', path: 'new-part-bl'
      get 'load_part_bl', path: 'load-part-bl'
      get 'calculate_invoice'
      get 'view_calculate_invoice'
      match 'update_calculate_invoice', via: [:put, :patch]
      get 'import_data'
      post 'report'
    end
  end
  resources :reports do
    collection do
      get 'check_si_exists'
      get 'list_si'
      get 'shipments_tracking'
      get 'invoices'
      get 'payments'
      get 'control_center'
      get 'outstanding_invoices'
      get 'invoices_unpaid'
      get 'cost_revenue_analysis_index'
      get 'balance_index'
      get 'detail_shipment_index'
      post 'cost_revenue_analysis'
      post 'balance'
      post 'detail_shipment'
    end
  end
  resources :shipment_trackings, only: [:index, :edit, :update, :report] do
    member do
      get 'ft_email'
      get 'etd_email'
      get 'eta_email'
    end
    collection do
      post 'update_shipment'
      post 'update_actual_shipment'
      post 'report'
    end
  end
  resources :shipping_instructions do
    member do
      get 'print'
      get 'history'
      get 'cancel'
      get 'uncancel'
      get 'email'
    end
    collection do
      get 'new_add_si', path: 'new-add-si'
      get 'load_add_si', path: 'load-add-si'
      get 'update_shipment'
      get 'import_data'
      post 'report'
    end
  end
  resources :cost_revenues do
    collection do
      get 'import_data'
      get 'duplicate_si', path: 'duplicate_si'
      get 'load_duplicate_si', path: 'load_duplicate_si'
      post 'create_duplicate_si', path: 'create_duplicate_si'
      post 'report'
      get 'print'
    end
    member do
      match 'update_status', path: 'update-status', via: [:put, :patch]
      get 'close_cost_revenue', as: 'close'
      get 'print_cover'
    end
  end

  resources :payment_plans, :payment_inquiries, :payment_taxes, :payment_deposits, :payment_reports, only: [:index]
  resources :payment_plans do
    collection do 
      post 'report'
    end
  end
  resources :payment_inquiries do
    collection do 
      match 'update_status', path: 'update-status', via: [:put, :patch]
      post 'report'
    end
  end
  resource :payment_taxes do
    collection do
      get 'update_status'
      post 'update_tax'
      post 'report'
    end
  end
  resource :payment_deposits do
    collection do
      get 'view'
      match 'close', via: [:post, :put, :patch]
      post 'report'
    end
  end


  # resources :control_centers, only: [:index] do
  #   collection do
  #     # get 'control_center'
  #     get 'short_paid'
  #     get 'deposit'
  #   end
  # end
  resources :control_centers do
    collection do
      post 'report'
      # post 'report_short_paid'
      # post 'report_deposit'
      # get 'short_paid'
      # get 'deposit'
      get 'payment'
      match 'update_payment', via: [:put, :patch]
      post 'close_payment'
      get 'edit_close_payment'
      # get 'close_payment'
      match 'update_close_payment', via: [:put, :patch]
      get 'view'
    end
  end

  resources :control_center_short_paids do
    collection do
      post 'report'
      get 'view'
      post 'update_short_paid'
    end
  end

  resources :control_center_deposits do
    collection do
      post 'report'
      get 'view'
      post 'update_deposit'
      match 'close', via: [:post, :put, :patch]
    end
  end

  # get 'control_center', to: 'control_center#index', as: 'control_center'
  # post 'control_center/report', to: 'control_center#report', as: 'report_control_center'
  # get 'control_center/short_paid', to: 'control_center#short_paid', as: 'short_paid'
  # get 'control_center/deposit', to: 'control_center#deposit', as: 'deposit'

  post 'control_center/report', to: 'control_center#report', as: 'report_control_center'

  resources :carriers, :shippers do
    member do
      match 'update_charges', path: 'update-charges', via: [:put, :patch]
      get 'charges'
    end
  end

  resources :agents, :consignees, :shippers, :users, :carriers, :carrier_banks, :owners do
    collection do
      post 'report'
    end
    member do
      get 'enable'
    end
  end

  resources :containers
  resources :banks
  resources :sessions
  
  get 'createBL/:sid', to: 'bill_of_ladings#create_bl', as: :create_bl
  get 'createInvoice/:bid', to: 'invoices#create_invoice', as: :create_invoice
  get 'createDBN/:bid', to: 'debit_notes#create_dbn', as: :create_dbn
  get 'createNote/:bid', to: 'notes#create_note', as: :create_note
  get 'create-new-invoice/:bid', to: 'home#create_new_invoice', as: :create_new_invoice
  get 'invoiceDetails/:no_invoice', to: 'invoices#details'
  get 'generatePaymentNumber/:type', to: 'payments#generate_number'
  get 'payments-list', to: 'payments#payments_list'
  get 'load-si-data', to: 'shipping_instructions#load_data_si'
  get 'get-booking-no', to: 'shipping_instructions#booking_no', as: 'get_booking_no'

  get 'get-master-bl-no', to: 'shipping_instructions#master_bl_no', as: 'get_master_bl_no'
  get 'get-ibl-deposit', to: 'payments#ibl_deposit', as: 'get_ibl_deposit'
  get 'update-delivery-doc', to: 'bill_of_ladings#update_delivery_doc', as: 'update_delivery_doc'
  get 'get-shipment-comparison', to: 'cost_revenues#shipment_comparison_data', as: 'get_shipment_comparison'
  get 'get-cost-comparison', to: 'cost_revenues#cost_comparison_data', as: 'get_cost_comparison'
  get 'get-sell-comparison', to: 'cost_revenues#sell_comparison_data', as: 'get_sell_comparison'
  get 'get-cnr-analysis', to: 'cost_revenues#cnr_analysis', as: 'get_cnr_analysis'
  get 'get-shipper-charges', to: 'shippers#shipper_charges', as: 'get_shipper_charges'
  get 'get-carrier-charges', to: 'carriers#carrier_charges', as: 'get_carrier_charges'
  get 'get-ibl-ref-with-invoice-no', to: 'control_centers#ibl_ref_with_invoice_no', as: 'get_ibl_ref_with_invoice_no'
  get 'get-invoice-deposit', to: 'control_centers#invoice_deposit', as: 'get_invoice_deposit'


  get 'carrier_details/:cid', to: 'carrier_banks#carrier_details'
  get 'get-due-date/:type/:id/:bl_id', to: 'home#get_due_date', as: 'get_due_date'

  # Revisi 1 Dec 2015
  get 'duplicateSI/:no_si', to: 'shipping_instructions#duplicate_si', as: :duplicate_si
  
  # get 'control-center', to: 'home#control_center', as: 'control_center'
  get 'outstanding-bonshipment', to: 'home#outstanding_bonshipment', as: 'outstanding_bonshipment'
  get 'report-tracking', to: 'home#report_tracking', as: 'report_tracking'
  get 'list-tracking/:bid', to: 'home#list_tracking', as: 'list_tracking'

  post 'update-tracking', to: 'home#update_tracking'
  match 'create_add_si', to: 'shipping_instructions#create_add_si', path: 'create-add-si', as: 'create_add_si_shipping_instructions', via: [:post, :patch, :put]
  match 'create_part_bl', to: 'bill_of_ladings#create_part_bl', path: 'create-part-bl', as: 'create_part_bl_bill_of_ladings', via: [:post, :patch, :put]

  match 'search-control', to: 'home#search_control_center', as: 'search_control', via: :all
  match 'search-outstanding-bonshipment', to: 'home#search_outstanding_bonshipment', as: 'search_bonshipment', via: :all
  get 'list-inv-dbn', to: 'home#list_inv_dbn', as: :list_inv_dbn

  get 'destroy', to: 'home#destroy'
  get 'update_invoice', to: 'home#update_invoice'
  get 'backup', to: 'home#backup', as: 'backup'
  get 'db_backup', to: 'home#db_backup', as: 'db_backup'
  post 'db_restore', to: 'home#db_restore', as: 'db_restore'

  get 'monitoring_data_refresh', to: 'home#monitoring_data_refresh'

  root 'home#index'

  namespace :api do
    resource :trackings, only: [] do
      get :shipment
    end
  end

  mount Sidekiq::Web, at: "/background-jobs"
end
