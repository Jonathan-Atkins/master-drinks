require "rails_helper"

RSpec.describe FunFact, type: :model do
  describe "validations" do
    describe "happy path" do
      it "is valid with all required attributes" do
        fun_fact = FunFact.new(
          body: "The Negroni is associated with Florence, Italy.",
          drink_name: "Negroni"
        )

        expect(fun_fact).to be_valid
      end
    end

    describe "sad path" do
      it "is invalid without a body" do
        fun_fact = FunFact.new(
          drink_name: "Negroni"
        )

        expect(fun_fact).not_to be_valid
        expect(fun_fact.errors[:body]).to include("can't be blank")
      end

      it "is invalid without a drink name" do
        fun_fact = FunFact.new(
          body: "The Negroni is associated with Florence, Italy."
        )

        expect(fun_fact).not_to be_valid
        expect(fun_fact.errors[:drink_name]).to include("can't be blank")
      end
    end
  end
end
