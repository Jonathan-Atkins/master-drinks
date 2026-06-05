class Api::V1::DrinksController < ApplicationController
  def index
    require 'pry-nav'; binding.pry
    drinks = Drink.all
  end
end