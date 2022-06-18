json.array!(@cost_revenues) do |cost_revenue|
  json.extract! cost_revenue, :shipping_instruction_id, :payment_no
  json.url cost_revenue_url(cost_revenue, format: :json)
end
