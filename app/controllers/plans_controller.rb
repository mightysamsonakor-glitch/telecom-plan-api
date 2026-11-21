class PlansController < ApplicationController
  def show
    render json: plan_json(Plan.find(params[:id]))
  end

  # Creates the customer (if new), the plan and its items in one transaction:
  # if any option is invalid, nothing is saved.
  def create
    plan = Plan.transaction do
      customer = Customer.find_or_create_by!(email: customer_params[:email]) do |new_customer|
        new_customer.full_name = customer_params[:full_name]
      end
      term = ContractTerm.find_by!(months: params.require(:contract_months))
      new_plan = customer.plans.create!(name: params.require(:name), contract_term: term)

      Array(params.require(:option_ids)).each do |option_id|
        new_plan.plan_items.create!(component_option: ComponentOption.available.find(option_id))
      end
      new_plan
    end

    render json: plan_json(plan), status: :created
  end

  def activate
    plan = Plan.find(params[:id])
    plan.activate!
    render json: plan_json(plan)
  end

  private

  def customer_params
    params.require(:customer).permit(:full_name, :email)
  end

  def plan_json(plan)
    items = plan.plan_items.includes(:component, component_option: :component).map do |item|
      {
        component: item.component.code,
        option: item.component_option.label,
        monthly_price_cents: item.component_option.monthly_price_cents
      }
    end

    {
      id: plan.id,
      name: plan.name,
      status: plan.status,
      customer: { full_name: plan.customer.full_name, email: plan.customer.email },
      contract_months: plan.contract_term.months,
      discount_percent: plan.contract_term.discount_percent,
      items: items,
      base_price_cents: plan.base_price_cents,
      monthly_price_cents: plan.monthly_price_cents,
      activated_at: plan.activated_at
    }
  end
end
