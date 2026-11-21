class ContractTermsController < ApplicationController
  def index
    terms = ContractTerm.order(:months).map do |term|
      { months: term.months, discount_percent: term.discount_percent }
    end

    render json: terms
  end
end
