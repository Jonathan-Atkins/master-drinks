require "rails_helper"

RSpec.describe FunFactPoolBuilder do
  describe ".call" do
    describe "happy path" do
      it "builds facts from distinct publicly visible drink names" do
        category = Category.create!(
          name: "Cocktails",
          slug: "cocktails"
        )

        user_one = User.create!(
          name: "Alice",
          username: "alice",
          email: "alice@example.com",
          password: "12345",
          password_confirmation: "12345"
        )

        user_two = User.create!(
          name: "Bob",
          username: "bob",
          email: "bob@example.com",
          password: "12345",
          password_confirmation: "12345"
        )

        Drink.create!(
          user: user_one,
          name: "Negroni",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        Drink.create!(
          user: user_two,
          name: "Negroni",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        Drink.create!(
          user: user_one,
          name: "Margarita",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        Drink.create!(
          user: user_one,
          name: "Secret Punch",
          alcoholic: true,
          publicly_visible: false,
          categories: [ category ]
        )

        allow(WikimediaFactImporter)
          .to receive(:import) do |drink_name|
            FunFact.new(
              body: "#{drink_name} fact",
              drink_name: drink_name
            )
          end

        facts = described_class.call

        expect(
          facts.map(&:drink_name)
        ).to contain_exactly(
          "Negroni",
          "Margarita"
        )

        expect(WikimediaFactImporter)
          .to have_received(:import)
          .with("Negroni")
          .once

        expect(WikimediaFactImporter)
          .to have_received(:import)
          .with("Margarita")
          .once

        expect(WikimediaFactImporter)
          .not_to have_received(:import)
          .with("Secret Punch")
      end

      it "returns no more than 20 facts" do
        category = Category.create!(
          name: "Cocktails",
          slug: "cocktails"
        )

        user = User.create!(
          name: "Alice",
          username: "alice",
          email: "alice@example.com",
          password: "12345",
          password_confirmation: "12345"
        )

        25.times do |number|
          Drink.create!(
            user: user,
            name: "Drink #{number}",
            alcoholic: true,
            publicly_visible: true,
            categories: [ category ]
          )
        end

        allow(WikimediaFactImporter)
          .to receive(:import) do |drink_name|
            FunFact.new(
              body: "#{drink_name} fact",
              drink_name: drink_name
            )
          end

        facts = described_class.call

        expect(facts.size).to eq(20)

        expect(WikimediaFactImporter)
          .to have_received(:import)
          .exactly(20)
          .times
      end
    end

    describe "sad path" do
      it "skips a drink when no fun fact can be produced" do
        category = Category.create!(
          name: "Cocktails",
          slug: "cocktails"
        )

        user = User.create!(
          name: "Alice",
          username: "alice",
          email: "alice@example.com",
          password: "12345",
          password_confirmation: "12345"
        )

        Drink.create!(
          user: user,
          name: "Negroni",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        Drink.create!(
          user: user,
          name: "Jonathan's Fire Water",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        allow(WikimediaFactImporter)
          .to receive(:import) do |drink_name|
            if drink_name == "Jonathan's Fire Water"
              nil
            else
              FunFact.new(
                body: "#{drink_name} fact",
                drink_name: drink_name
              )
            end
          end

        facts = described_class.call

        expect(
          facts.map(&:drink_name)
        ).to eq([
          "Negroni"
        ])
      end
    end
  end
end
