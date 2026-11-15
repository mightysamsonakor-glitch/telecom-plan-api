require "test_helper"

class ComponentOptionTest < ActiveSupport::TestCase
  setup do
    @data = Component.create!(code: "DATA", name: "Mobile data", unit: "GB")
  end

  test "an unlimited option cannot also have an amount" do
    assert_not @data.component_options.build(unlimited: true, amount: 10, monthly_price_cents: 100).valid?
  end

  test "a fixed option needs a positive amount" do
    assert_not @data.component_options.build(amount: nil, monthly_price_cents: 100).valid?
    assert_not @data.component_options.build(amount: 0, monthly_price_cents: 100).valid?
  end

  test "builds a readable label" do
    assert_equal "20 GB", @data.component_options.build(amount: 20).label
    assert_equal "unlimited GB", @data.component_options.build(unlimited: true).label
  end
end
