class Api::V1::FunFactsController < ApplicationController
  skip_before_action :require_login, only: [ :index ]

  def index
    fun_facts = FunFactPoolBuilder.call

    render json: fun_facts, status: :ok
  end
end
