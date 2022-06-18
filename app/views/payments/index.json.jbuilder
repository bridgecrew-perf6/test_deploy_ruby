json.array!(@payments) do |payment|
  json.extract! payment, :invoice_id, :bank_id, :payment_date, :payment_no, :amount
  json.url payment_url(payment, format: :json)
end
