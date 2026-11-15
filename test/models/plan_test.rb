require "test_helper"

class PlanTest < ActiveSupport::TestCase
  setup do
    @data = Component.create!(code: "DATA", name: "Mobile data", unit: "GB")
    @minutes = Component.create!(code: "MINUTES", name: "Call minutes", unit: "min")
    @gb20 = @data.component_options.create!(amount: 20, monthly_price_cents: 699)
    @unlimited_min = @minutes.component_options.create!(unlimited: true, monthly_price_cents: 599)
    @term = ContractTerm.create!(months: 12, discount_percent: 10)
    @customer = Customer.create!(full_name: "Test User", email: "test@example.com")
    @plan = Plan.create!(customer: @customer, contract_term: @term, name: "My plan")
  end

  test "calculates the monthly price with the contract discount" do
    @plan.plan_items.create!(component_option: @gb20)
    @plan.plan_items.create!(component_option: @unlimited_min)

    assert_equal 1298, @plan.base_price_cents
    assert_equal 1168, @plan.monthly_price_cents
  end

  test "allows only one option per component" do
    @plan.plan_items.create!(component_option: @gb20)
    gb5 = @data.component_options.create!(amount: 5, monthly_price_cents: 399)

    assert_not @plan.plan_items.build(component_option: gb5).valid?
  end

  test "rejects an option placed under the wrong component" do
    item = @plan.plan_items.build(component: @minutes, component_option: @gb20)

    assert_not item.valid?
    assert_includes item.errors[:component_option], "does not belong to MINUTES"
  end

  test "new plans start as draft and can be activated" do
    assert @plan.draft?

    @plan.activate!

    assert @plan.active?
    assert_not_nil @plan.activated_at
  end
end
