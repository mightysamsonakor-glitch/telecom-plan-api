data    = Component.find_or_create_by!(code: "DATA")    { |c| c.name = "Mobile data";   c.unit = "GB" }
minutes = Component.find_or_create_by!(code: "MINUTES") { |c| c.name = "Call minutes";  c.unit = "min" }
sms     = Component.find_or_create_by!(code: "SMS")     { |c| c.name = "Text messages"; c.unit = "SMS" }

[
  [ data, 5, 399 ], [ data, 20, 699 ], [ data, 50, 999 ], [ data, nil, 1499 ],
  [ minutes, 100, 199 ], [ minutes, 500, 399 ], [ minutes, nil, 599 ],
  [ sms, 50, 99 ], [ sms, nil, 299 ]
].each do |component, amount, price|
  component.component_options.find_or_create_by!(amount: amount, unlimited: amount.nil?) do |option|
    option.monthly_price_cents = price
  end
end

{ 1 => 0, 12 => 10, 24 => 20 }.each do |months, discount|
  ContractTerm.find_or_create_by!(months: months) { |term| term.discount_percent = discount }
end

puts "Seeded #{ComponentOption.count} options and #{ContractTerm.count} contract terms"
