# frozen_string_literal: true

# Copy this file to db/seeds/ingredients.rb, then load it from db/seeds.rb with:
#   load Rails.root.join("db/seeds/ingredients.rb")
#
# This seed is idempotent: running it repeatedly will not create exact duplicates.

ingredient_groups = {
  base_spirits: [
    "Vodka", "Citrus Vodka", "Vanilla Vodka", "Pepper Vodka", "Gin",
    "London Dry Gin", "Old Tom Gin", "Plymouth Gin", "Navy Strength Gin",
    "Genever", "White Rum", "Light Rum", "Gold Rum", "Dark Rum", "Black Rum",
    "Aged Rum", "Spiced Rum", "Overproof Rum", "Navy Strength Rum",
    "Demerara Rum", "Jamaican Rum", "Cuban-Style Rum", "Barbados Rum",
    "Puerto Rican Rum", "Rhum Agricole Blanc", "Rhum Agricole Vieux", "Cachaça",
    "Tequila Blanco", "Tequila Reposado", "Tequila Añejo",
    "Tequila Extra Añejo", "Cristalino Tequila", "Mezcal", "Espadín Mezcal",
    "Tobalá Mezcal", "Raicilla", "Sotol", "Bourbon", "Rye Whiskey",
    "American Whiskey", "Tennessee Whiskey", "Canadian Whisky", "Irish Whiskey",
    "Blended Scotch", "Single Malt Scotch", "Peated Scotch", "Japanese Whisky",
    "Corn Whiskey", "Wheat Whiskey", "Moonshine", "Brandy", "Cognac",
    "Armagnac", "Calvados", "Apple Brandy", "Pear Brandy", "Pisco", "Grappa",
    "Singani", "Aquavit", "Arrack", "Batavia Arrack", "Arak", "Ouzo", "Rakı",
    "Baijiu", "Shochu", "Soju", "Sake", "Absinthe"
  ],

  liqueurs_and_cordials: [
    "Orange Curaçao", "Dry Curaçao", "Blue Curaçao", "Triple Sec",
    "Orange Liqueur", "Mandarin Liqueur", "Blood Orange Liqueur", "Limoncello",
    "Lime Liqueur", "Grapefruit Liqueur", "Yuzu Liqueur", "Bergamot Liqueur",
    "Cherry Liqueur", "Maraschino Liqueur", "Cherry Heering", "Black Raspberry Liqueur",
    "Raspberry Liqueur", "Strawberry Liqueur", "Blackberry Liqueur",
    "Blueberry Liqueur", "Cranberry Liqueur", "Pomegranate Liqueur",
    "Peach Liqueur", "Apricot Liqueur", "Pear Liqueur", "Apple Liqueur",
    "Green Apple Liqueur", "Banana Liqueur", "Pineapple Liqueur", "Mango Liqueur",
    "Passion Fruit Liqueur", "Lychee Liqueur", "Melon Liqueur",
    "Watermelon Liqueur", "Coconut Liqueur", "Fig Liqueur", "Date Liqueur",
    "Elderflower Liqueur", "Crème de Cassis", "Crème de Mûre", "Crème de Fraise",
    "Crème de Framboise", "Crème de Pêche", "Crème de Banane",
    "Crème de Menthe", "White Crème de Menthe", "Green Crème de Menthe",
    "Crème de Cacao", "White Crème de Cacao", "Dark Crème de Cacao",
    "Crème de Violette", "Crème Yvette", "Crème de Noyaux", "Crème de Rose",
    "Crème de Café", "Coffee Liqueur", "Espresso Liqueur", "Chocolate Liqueur",
    "White Chocolate Liqueur", "Hazelnut Liqueur", "Almond Liqueur",
    "Walnut Liqueur", "Pistachio Liqueur", "Macadamia Liqueur",
    "Peanut Butter Liqueur", "Vanilla Liqueur", "Caramel Liqueur",
    "Butterscotch Liqueur", "Honey Liqueur", "Maple Liqueur", "Ginger Liqueur",
    "Cinnamon Liqueur", "Anise Liqueur", "Licorice Liqueur", "Herbal Liqueur",
    "Green Herbal Liqueur", "Yellow Herbal Liqueur", "Bénédictine",
    "Galliano", "Drambuie", "Amaretto", "Frangelico", "Irish Cream Liqueur",
    "Cream Liqueur", "Advocaat", "Rock and Rye", "Southern Comfort",
    "Swedish Punsch", "Falernum Liqueur", "Allspice Dram", "Ancho Chile Liqueur",
    "Chile Liqueur", "Jalapeño Liqueur", "Cardamom Liqueur", "Saffron Liqueur",
    "Tea Liqueur", "Green Tea Liqueur", "Chai Liqueur", "Sake Liqueur"
  ],

  amari_aperitifs_and_fortified_wines: [
    "Campari", "Aperol", "Red Bitter Aperitif", "White Bitter Aperitif",
    "Gentian Aperitif", "Suze", "Salers", "Cynar", "Fernet-Branca", "Fernet",
    "Mint Fernet", "Amaro", "Light Amaro", "Dark Amaro", "Alpine Amaro",
    "Rabarbaro", "Quinquina", "Americano Aperitif", "Lillet Blanc", "Lillet Rosé",
    "Cocchi Americano", "Cocchi Rosa", "Dubonnet Rouge", "Sweet Vermouth",
    "Dry Vermouth", "Blanc Vermouth", "Rosé Vermouth", "Spanish Vermouth",
    "Italian Sweet Vermouth", "French Dry Vermouth", "Sherry", "Fino Sherry",
    "Manzanilla Sherry", "Amontillado Sherry", "Oloroso Sherry",
    "Palo Cortado Sherry", "Pedro Ximénez Sherry", "Cream Sherry", "Madeira",
    "Sercial Madeira", "Verdelho Madeira", "Bual Madeira", "Malmsey Madeira",
    "Port", "Ruby Port", "Tawny Port", "White Port", "Late Bottled Vintage Port",
    "Marsala", "Dry Marsala", "Sweet Marsala", "Pineau des Charentes",
    "Floc de Gascogne", "Mistelle", "Vermouth Amaro"
  ],

  wines_beers_and_ciders: [
    "Red Wine", "White Wine", "Rosé Wine", "Dry Red Wine", "Dry White Wine",
    "Sweet White Wine", "Dessert Wine", "Sauvignon Blanc", "Chardonnay",
    "Riesling", "Pinot Grigio", "Chenin Blanc", "Gewürztraminer", "Pinot Noir",
    "Cabernet Sauvignon", "Merlot", "Malbec", "Syrah", "Zinfandel",
    "Tempranillo", "Sangria", "Champagne", "Brut Champagne", "Rosé Champagne",
    "Sparkling Wine", "Brut Sparkling Wine", "Prosecco", "Cava", "Sparkling Rosé",
    "Lambrusco", "Beer", "Lager", "Pilsner", "Pale Ale", "India Pale Ale",
    "Wheat Beer", "Hefeweizen", "Saison", "Belgian Ale", "Brown Ale", "Porter",
    "Stout", "Imperial Stout", "Sour Beer", "Gose", "Lambic", "Hard Cider",
    "Dry Cider", "Sweet Cider", "Pear Cider", "Apple Cider", "Mulled Wine"
  ],

  juices: [
    "Lemon Juice", "Lime Juice", "Key Lime Juice", "Orange Juice",
    "Blood Orange Juice", "Grapefruit Juice", "White Grapefruit Juice",
    "Pink Grapefruit Juice", "Pineapple Juice", "Cranberry Juice",
    "White Cranberry Juice", "Pomegranate Juice", "Apple Juice",
    "Green Apple Juice", "Pear Juice", "Peach Juice", "Apricot Juice",
    "Mango Juice", "Passion Fruit Juice", "Guava Juice", "Lychee Juice",
    "Watermelon Juice", "Cantaloupe Juice", "Honeydew Juice", "Strawberry Juice",
    "Raspberry Juice", "Blackberry Juice", "Blueberry Juice", "Cherry Juice",
    "Tart Cherry Juice", "Grape Juice", "Concord Grape Juice", "Tomato Juice",
    "Carrot Juice", "Beet Juice", "Celery Juice", "Cucumber Juice",
    "Coconut Water", "Aloe Vera Juice", "Yuzu Juice", "Calamansi Juice",
    "Sudachi Juice", "Kabosu Juice", "Bergamot Juice", "Mandarin Juice",
    "Tangerine Juice", "Clementine Juice", "Pomelo Juice", "Meyer Lemon Juice"
  ],

  purees_pulps_and_preserves: [
    "Passion Fruit Purée", "Mango Purée", "Peach Purée", "Apricot Purée",
    "Pear Purée", "Apple Purée", "Strawberry Purée", "Raspberry Purée",
    "Blackberry Purée", "Blueberry Purée", "Cherry Purée", "Pineapple Purée",
    "Guava Purée", "Lychee Purée", "Watermelon Purée", "Cantaloupe Purée",
    "Honeydew Purée", "Banana Purée", "Coconut Purée", "Dragon Fruit Purée",
    "Kiwi Purée", "Fig Purée", "Date Purée", "Persimmon Purée", "Pumpkin Purée",
    "Tamarind Purée", "Passion Fruit Pulp", "Tamarind Paste", "Guava Paste",
    "Fig Jam", "Apricot Jam", "Raspberry Jam", "Strawberry Jam", "Blackberry Jam",
    "Orange Marmalade", "Lemon Marmalade", "Grapefruit Marmalade",
    "Cherry Preserves", "Peach Preserves", "Apple Butter", "Pumpkin Butter",
    "Coconut Cream", "Cream of Coconut"
  ],

  syrups_sweeteners_and_sugars: [
    "Simple Syrup", "Rich Simple Syrup", "Demerara Syrup", "Brown Sugar Syrup",
    "Turbinado Syrup", "Cane Syrup", "Raw Sugar Syrup", "White Sugar",
    "Granulated Sugar", "Caster Sugar", "Powdered Sugar", "Brown Sugar",
    "Light Brown Sugar", "Dark Brown Sugar", "Demerara Sugar", "Turbinado Sugar",
    "Sugar Cube", "Honey", "Honey Syrup", "Agave Nectar", "Agave Syrup",
    "Maple Syrup", "Molasses", "Blackstrap Molasses", "Golden Syrup", "Gomme Syrup",
    "Orgeat", "Almond Syrup", "Hazelnut Syrup", "Pistachio Syrup",
    "Macadamia Syrup", "Peanut Syrup", "Vanilla Syrup", "Caramel Syrup",
    "Salted Caramel Syrup", "Chocolate Syrup", "White Chocolate Syrup",
    "Cocoa Syrup", "Coffee Syrup", "Espresso Syrup", "Cinnamon Syrup",
    "Ginger Syrup", "Cardamom Syrup", "Clove Syrup", "Allspice Syrup",
    "Star Anise Syrup", "Chai Syrup", "Tea Syrup", "Green Tea Syrup",
    "Earl Grey Syrup", "Hibiscus Syrup", "Rose Syrup", "Lavender Syrup",
    "Violet Syrup", "Elderflower Syrup", "Chamomile Syrup", "Jasmine Syrup",
    "Mint Syrup", "Basil Syrup", "Rosemary Syrup", "Thyme Syrup", "Sage Syrup",
    "Lemongrass Syrup", "Peppercorn Syrup", "Chile Syrup", "Jalapeño Syrup",
    "Habanero Syrup", "Ancho Chile Syrup", "Smoked Syrup", "Cola Syrup",
    "Root Beer Syrup", "Tonic Syrup", "Grenadine", "Pomegranate Syrup",
    "Cherry Syrup", "Raspberry Syrup", "Strawberry Syrup", "Blackberry Syrup",
    "Blueberry Syrup", "Peach Syrup", "Apricot Syrup", "Pear Syrup",
    "Apple Syrup", "Pineapple Syrup", "Mango Syrup", "Passion Fruit Syrup",
    "Guava Syrup", "Lychee Syrup", "Watermelon Syrup", "Coconut Syrup",
    "Banana Syrup", "Fig Syrup", "Date Syrup", "Tamarind Syrup", "Yuzu Syrup",
    "Lime Cordial", "Lemon Cordial", "Grapefruit Cordial", "Orange Cordial",
    "Blackcurrant Cordial", "Elderflower Cordial", "Passion Fruit Cordial",
    "Pineapple Cordial", "Ginger Cordial", "Shrub", "Apple Shrub", "Pear Shrub",
    "Strawberry Shrub", "Raspberry Shrub", "Pineapple Shrub", "Peach Shrub",
    "Blackberry Shrub", "Ginger Shrub"
  ],

  bitters_tinctures_and_acids: [
    "Aromatic Bitters", "Angostura Bitters", "Orange Bitters", "Grapefruit Bitters",
    "Lemon Bitters", "Lime Bitters", "Peychaud's Bitters", "Chocolate Bitters",
    "Mole Bitters", "Coffee Bitters", "Cherry Bitters", "Peach Bitters",
    "Plum Bitters", "Rhubarb Bitters", "Celery Bitters", "Cucumber Bitters",
    "Lavender Bitters", "Hibiscus Bitters", "Cardamom Bitters", "Cinnamon Bitters",
    "Ginger Bitters", "Black Walnut Bitters", "Almond Bitters", "Tiki Bitters",
    "Creole Bitters", "Old Fashioned Bitters", "Smoked Bitters",
    "Hopped Grapefruit Bitters", "Mint Bitters", "Rose Bitters", "Vanilla Bitters",
    "Chili Bitters", "Firewater Tincture", "Salt Tincture", "Saline Solution",
    "Citric Acid Solution", "Malic Acid Solution", "Tartaric Acid Solution",
    "Phosphoric Acid Solution", "Lactic Acid Solution", "Acid-Adjusted Citrus Juice",
    "Foaming Bitters"
  ],

  sodas_waters_and_non_alcoholic_mixers: [
    "Soda Water", "Club Soda", "Sparkling Water", "Mineral Water", "Still Water",
    "Hot Water", "Tonic Water", "Light Tonic Water", "Elderflower Tonic Water",
    "Mediterranean Tonic Water", "Cola", "Diet Cola", "Cherry Cola", "Vanilla Cola",
    "Lemon-Lime Soda", "Ginger Ale", "Ginger Beer", "Root Beer", "Cream Soda",
    "Grapefruit Soda", "Orange Soda", "Pineapple Soda", "Black Cherry Soda",
    "Birch Beer", "Bitter Lemon", "Lemonade", "Pink Lemonade", "Limeade",
    "Arnold Palmer", "Iced Tea", "Sweet Tea", "Black Tea", "Green Tea", "White Tea",
    "Oolong Tea", "Earl Grey Tea", "English Breakfast Tea", "Jasmine Tea",
    "Hibiscus Tea", "Chamomile Tea", "Chai Tea", "Matcha", "Yerba Mate", "Coffee",
    "Cold Brew Coffee", "Espresso", "Decaffeinated Coffee", "Hot Chocolate",
    "Chocolate Milk", "Energy Drink", "Coconut Soda", "Aloe Drink", "Kombucha",
    "Ginger Kombucha", "Berry Kombucha", "Hop Water", "Nonalcoholic Sparkling Wine",
    "Nonalcoholic Beer", "Nonalcoholic Spirit", "Nonalcoholic Aperitif",
    "Nonalcoholic Vermouth", "Nonalcoholic Bitters"
  ],

  dairy_eggs_and_foaming_ingredients: [
    "Heavy Cream", "Light Cream", "Half-and-Half", "Whole Milk", "Two Percent Milk",
    "Skim Milk", "Condensed Milk", "Sweetened Condensed Milk", "Evaporated Milk",
    "Buttermilk", "Coconut Milk", "Oat Milk", "Almond Milk", "Soy Milk",
    "Cashew Milk", "Rice Milk", "Cream Cheese", "Mascarpone", "Vanilla Ice Cream",
    "Chocolate Ice Cream", "Coffee Ice Cream", "Coconut Ice Cream", "Sorbet",
    "Lemon Sorbet", "Raspberry Sorbet", "Egg", "Egg White", "Egg Yolk", "Aquafaba",
    "Greek Yogurt", "Plain Yogurt", "Coconut Yogurt", "Whipped Cream"
  ],

  fresh_fruits_and_vegetables: [
    "Lemon", "Lime", "Key Lime", "Orange", "Blood Orange", "Grapefruit",
    "Pink Grapefruit", "White Grapefruit", "Mandarin", "Tangerine", "Clementine",
    "Pomelo", "Yuzu", "Calamansi", "Sudachi", "Kabosu", "Bergamot", "Pineapple",
    "Apple", "Green Apple", "Red Apple", "Pear", "Peach", "Nectarine", "Apricot",
    "Plum", "Cherry", "Black Cherry", "Strawberry", "Raspberry", "Blackberry",
    "Blueberry", "Cranberry", "Pomegranate", "Grapes", "Concord Grapes", "Mango",
    "Passion Fruit", "Guava", "Lychee", "Watermelon", "Cantaloupe", "Honeydew",
    "Banana", "Coconut", "Kiwi", "Dragon Fruit", "Papaya", "Fig", "Date",
    "Persimmon", "Tamarind", "Star Fruit", "Prickly Pear", "Cucumber", "Celery",
    "Tomato", "Cherry Tomato", "Carrot", "Beet", "Bell Pepper", "Red Bell Pepper",
    "Green Bell Pepper", "Jalapeño", "Serrano Pepper", "Habanero Pepper",
    "Ancho Chile", "Chipotle Pepper", "Ginger Root", "Turmeric Root", "Horseradish",
    "Rhubarb", "Pumpkin", "Sweet Potato", "Avocado", "Olive", "Pickle",
    "Cocktail Onion"
  ],

  herbs_flowers_and_botanicals: [
    "Mint", "Spearmint", "Peppermint", "Basil", "Thai Basil", "Purple Basil",
    "Rosemary", "Thyme", "Lemon Thyme", "Sage", "Tarragon", "Cilantro", "Parsley",
    "Dill", "Lemongrass", "Lemon Balm", "Shiso", "Green Shiso", "Red Shiso",
    "Makrut Lime Leaf", "Bay Leaf", "Pandan Leaf", "Curry Leaf", "Fennel Frond",
    "Celery Leaf", "Rose Petals", "Lavender", "Hibiscus", "Chamomile", "Jasmine",
    "Elderflower", "Violet", "Orange Blossom", "Cherry Blossom",
    "Butterfly Pea Flower", "Osmanthus", "Orchid", "Nasturtium", "Borage",
    "Marigold", "Edible Flowers", "Juniper Berries"
  ],

  spices_seasonings_and_savory_ingredients: [
    "Cinnamon", "Cinnamon Stick", "Nutmeg", "Freshly Grated Nutmeg", "Clove",
    "Allspice", "Star Anise", "Anise Seed", "Cardamom", "Green Cardamom",
    "Black Cardamom", "Vanilla Bean", "Vanilla Extract", "Almond Extract",
    "Orange Blossom Water", "Rose Water", "Black Pepper", "White Pepper",
    "Pink Peppercorn", "Sichuan Peppercorn", "Salt", "Sea Salt", "Kosher Salt",
    "Flaky Sea Salt", "Smoked Salt", "Celery Salt", "Chile-Lime Seasoning",
    "Chile Powder", "Cayenne Pepper", "Paprika", "Smoked Paprika", "Chipotle Powder",
    "Cocoa Powder", "Cacao Nibs", "Espresso Powder", "Wasabi", "Hot Sauce",
    "Worcestershire Sauce", "Soy Sauce", "Fish Sauce", "Oyster Sauce", "Miso",
    "White Miso", "Red Miso", "Kimchi Brine", "Pickle Brine", "Olive Brine",
    "Jalapeño Brine", "Balsamic Vinegar", "Apple Cider Vinegar", "White Wine Vinegar",
    "Red Wine Vinegar", "Rice Vinegar", "Champagne Vinegar", "Sherry Vinegar",
    "Coconut Vinegar", "Verjus", "White Verjus", "Red Verjus"
  ],

  garnishes_rims_and_ice: [
    "Lemon Peel", "Lime Peel", "Orange Peel", "Grapefruit Peel", "Lemon Wedge",
    "Lime Wedge", "Orange Wedge", "Grapefruit Wedge", "Lemon Wheel", "Lime Wheel",
    "Orange Wheel", "Grapefruit Wheel", "Dehydrated Lemon Wheel",
    "Dehydrated Lime Wheel", "Dehydrated Orange Wheel", "Dehydrated Grapefruit Wheel",
    "Brandied Cherry", "Maraschino Cherry", "Cocktail Cherry", "Luxardo Cherry",
    "Blue Cheese-Stuffed Olive", "Pickle Spear", "Cucumber Ribbon", "Celery Stalk",
    "Pineapple Wedge", "Pineapple Frond", "Mint Sprig", "Rosemary Sprig",
    "Thyme Sprig", "Basil Leaf", "Shiso Leaf", "Edible Flower", "Grated Cinnamon",
    "Grated Nutmeg", "Coffee Beans", "Chocolate Shavings", "Cocoa Dust", "Salt Rim",
    "Sugar Rim", "Cinnamon Sugar Rim", "Chile Salt Rim", "Smoked Salt Rim",
    "Coconut Flakes", "Toasted Coconut", "Crushed Ice", "Ice Cubes", "Large Ice Cube",
    "Pebble Ice", "Clear Ice"
  ],

  specialty_and_culinary_ingredients: [
    "Maraschino Cherry Syrup", "Cherry Syrup from Jar", "Maple Water", "Birch Syrup",
    "Sorghum Syrup", "Rice Syrup", "Palm Sugar Syrup", "Jaggery Syrup",
    "Coconut Sugar Syrup", "Malt Syrup", "Malt Extract", "Barley Water", "Rice Water",
    "Coconut Foam", "Vanilla Foam", "Citrus Foam", "Salted Foam", "Whipped Egg White",
    "Gelatin", "Agar-Agar", "Xanthan Gum", "Soy Lecithin", "Gum Arabic",
    "Methylcellulose", "Maltodextrin", "Liquid Smoke", "Smoked Tea",
    "Lapsang Souchong Tea", "Genmaicha Tea", "Hojicha Tea", "Pu-erh Tea",
    "Roasted Barley Tea", "Corn Tea", "Chrysanthemum Tea", "Butterfly Pea Tea",
    "Saffron", "Tonka Bean", "Black Sesame", "White Sesame", "Tahini",
    "Peanut Butter", "Almond Butter", "Hazelnut Spread", "Pistachio Paste",
    "Chestnut Purée", "Ube Purée", "Ube Extract", "Pandan Extract",
    "Coconut Extract", "Banana Extract", "Maple Extract", "Orange Extract",
    "Lemon Extract", "Mint Extract", "Ginger Extract", "Coffee Extract",
    "Black Garlic", "Truffle Honey", "Bacon", "Bacon Fat", "Brown Butter",
    "Clarified Butter", "Olive Oil", "Sesame Oil", "Coconut Oil", "Chili Oil",
    "Truffle Oil", "Balsamic Reduction"
  ]
}

# =========================
# Ingredient Metadata
# =========================

GROUP_METADATA = {
  base_spirits: {
    ingredient_type: "Spirit",
    flavor_profiles: [ "Dry" ]
  },
  liqueurs_and_cordials: {
    ingredient_type: "Liqueur",
    flavor_profiles: [ "Sweet", "Rich" ]
  },
  amari_aperitifs_and_fortified_wines: {
    ingredient_type: "Liqueur",
    flavor_profiles: [ "Bitter", "Herbal" ]
  },
  wines_beers_and_ciders: {
    ingredient_type: "Wine",
    flavor_profiles: [ "Dry", "Fruity" ]
  },
  juices: {
    ingredient_type: "Juice",
    flavor_profiles: [ "Fruity" ]
  },
  purees_pulps_and_preserves: {
    ingredient_type: "Other",
    flavor_profiles: [ "Fruity", "Sweet" ]
  },
  syrups_sweeteners_and_sugars: {
    ingredient_type: "Syrup",
    flavor_profiles: [ "Sweet" ]
  },
  bitters_tinctures_and_acids: {
    ingredient_type: "Bitters",
    flavor_profiles: [ "Bitter" ]
  },
  sodas_waters_and_non_alcoholic_mixers: {
    ingredient_type: "Mixer",
    flavor_profiles: [ "Dry" ]
  },
  dairy_eggs_and_foaming_ingredients: {
    ingredient_type: "Dairy",
    flavor_profiles: [ "Creamy", "Rich" ]
  },
  fresh_fruits_and_vegetables: {
    ingredient_type: "Other",
    flavor_profiles: [ "Fruity" ]
  },
  herbs_flowers_and_botanicals: {
    ingredient_type: "Herb",
    flavor_profiles: [ "Herbal" ]
  },
  spices_seasonings_and_savory_ingredients: {
    ingredient_type: "Spice",
    flavor_profiles: [ "Savory" ]
  },
  garnishes_rims_and_ice: {
    ingredient_type: "Garnish",
    flavor_profiles: []
  },
  specialty_and_culinary_ingredients: {
    ingredient_type: "Other",
    flavor_profiles: [ "Rich" ]
  }
}.freeze

CITRUS_TERMS = [
  "lemon", "lime", "orange", "grapefruit", "yuzu", "calamansi",
  "sudachi", "kabosu", "bergamot", "mandarin", "tangerine",
  "clementine", "pomelo"
].freeze

TROPICAL_TERMS = [
  "pineapple", "mango", "passion fruit", "guava", "lychee",
  "coconut", "banana", "papaya", "dragon fruit"
].freeze

FRUIT_TERMS = [
  "apple", "pear", "peach", "apricot", "plum", "cherry",
  "strawberry", "raspberry", "blackberry", "blueberry", "cranberry",
  "pomegranate", "grape", "fig", "melon", "kiwi", "persimmon"
].freeze

FLORAL_TERMS = [
  "rose", "lavender", "violet", "hibiscus", "elderflower", "jasmine",
  "chamomile", "orange blossom", "cherry blossom", "osmanthus",
  "butterfly pea", "flower"
].freeze

HERBAL_TERMS = [
  "mint", "basil", "rosemary", "thyme", "sage", "tarragon", "shiso",
  "lemongrass", "absinthe", "aquavit", "amaro", "fernet", "herbal",
  "pandan", "tea", "juniper"
].freeze

SPICY_TERMS = [
  "ginger", "cinnamon", "cardamom", "clove", "allspice", "pepper",
  "jalapeño", "habanero", "chile", "chili", "ancho", "cayenne",
  "horseradish", "wasabi"
].freeze

SMOKY_TERMS = [
  "mezcal", "peated", "smoked", "smoke", "lapsang", "chipotle"
].freeze

CREAMY_TERMS = [
  "cream", "milk", "yogurt", "egg", "aquafaba", "mascarpone",
  "butter", "tahini"
].freeze

SAVORY_TERMS = [
  "tomato", "celery", "cucumber", "olive", "pickle", "brine", "miso",
  "soy sauce", "fish sauce", "oyster sauce", "worcestershire", "bacon",
  "garlic", "salt", "avocado"
].freeze

RICH_TERMS = [
  "coffee", "espresso", "chocolate", "cacao", "cocoa", "caramel",
  "molasses", "butter", "maple", "vanilla", "nut", "sesame"
].freeze

SOUR_TERMS = [
  "vinegar", "acid", "verjus", "shrub", "sour", "lemonade", "limeade"
].freeze

BEER_TERMS = [
  "beer", "lager", "pilsner", "ale", "porter", "stout", "gose",
  "lambic", "hefeweizen", "saison"
].freeze

WINE_TERMS = [
  "vermouth", "wine", "champagne", "prosecco", "cava", "sherry",
  "port", "madeira", "marsala", "lillet", "cocchi", "dubonnet"
].freeze

HERB_TERMS = [
  "mint", "basil", "rosemary", "thyme", "sage", "tarragon", "cilantro",
  "parsley", "dill", "shiso", "lemongrass", "pandan", "bay leaf"
].freeze

SPICE_TERMS = [
  "cinnamon", "nutmeg", "clove", "cardamom", "peppercorn", "paprika",
  "cayenne", "allspice", "star anise", "saffron"
].freeze

SWEETENER_TERMS = [
  "sugar", "honey", "agave nectar", "molasses", "jaggery"
].freeze

# Returns the Type and Flavor Profiles for one seeded ingredient.
def ingredient_metadata_for(name, group_name)
  group_metadata = GROUP_METADATA.fetch(group_name)
  normalized_name = name.downcase

  ingredient_type = group_metadata[:ingredient_type]
  flavor_profiles = group_metadata[:flavor_profiles].dup

  if BEER_TERMS.any? { |term| normalized_name.include?(term) }
    ingredient_type = "Beer"
  elsif WINE_TERMS.any? { |term| normalized_name.include?(term) }
    ingredient_type = "Wine"
  elsif normalized_name.include?("syrup") || normalized_name.include?("cordial")
    ingredient_type = "Syrup"
  elsif SWEETENER_TERMS.any? { |term| normalized_name.include?(term) }
    ingredient_type = "Sweetener"
  elsif normalized_name.include?("juice")
    ingredient_type = "Juice"
  elsif normalized_name.include?("bitters")
    ingredient_type = "Bitters"
  elsif normalized_name.include?("liqueur") || normalized_name.include?("crème de") ||
        normalized_name.include?("advocaat") || normalized_name.include?("allspice dram") ||
        normalized_name.include?("amaretto") || normalized_name.include?("drambuie") ||
        normalized_name.include?("frangelico")
    ingredient_type = "Liqueur"
  elsif normalized_name.include?("cream") || normalized_name.include?("milk") ||
        normalized_name.include?("yogurt") || normalized_name.include?("ice cream")
    ingredient_type = "Dairy"
  elsif HERB_TERMS.any? { |term| normalized_name.include?(term) }
    ingredient_type = "Herb"
  elsif SPICE_TERMS.any? { |term| normalized_name.include?(term) }
    ingredient_type = "Spice"
  elsif group_name == :fresh_fruits_and_vegetables &&
        CITRUS_TERMS.any? { |term| normalized_name.include?(term) }
    ingredient_type = "Citrus"
  end

  if CITRUS_TERMS.any? { |term| normalized_name.include?(term) }
    flavor_profiles << "Citrusy"
    flavor_profiles << "Sour" if normalized_name.include?("juice")
  end

  if TROPICAL_TERMS.any? { |term| normalized_name.include?(term) }
    flavor_profiles << "Tropical"
    flavor_profiles << "Fruity"
  end

  flavor_profiles << "Fruity" if FRUIT_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Floral" if FLORAL_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Herbal" if HERBAL_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Spicy" if SPICY_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Smoky" if SMOKY_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Creamy" if CREAMY_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Savory" if SAVORY_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Rich" if RICH_TERMS.any? { |term| normalized_name.include?(term) }
  flavor_profiles << "Sour" if SOUR_TERMS.any? { |term| normalized_name.include?(term) }

  if normalized_name.include?("syrup") || normalized_name.include?("sugar") ||
     normalized_name.include?("honey") || normalized_name.include?("liqueur") ||
     normalized_name.include?("crème de") || normalized_name.include?("cordial") ||
     normalized_name.include?("grenadine")
    flavor_profiles << "Sweet"
  end

  if normalized_name.include?("bitters") || normalized_name.include?("amaro") ||
     normalized_name.include?("fernet") || normalized_name.include?("campari") ||
     normalized_name.include?("aperol")
    flavor_profiles << "Bitter"
  end

  flavor_profiles << "Dry" if normalized_name.include?("dry")

  flavor_profiles = flavor_profiles
    .uniq
    .select { |profile| Ingredient::FLAVOR_PROFILES.include?(profile) }

  {
    ingredient_type: ingredient_type,
    flavor_profiles: flavor_profiles
  }
end

# =========================
# Seed / Backfill Ingredient Metadata
# =========================

created_count = 0
updated_count = 0

Ingredient.transaction do
  ingredient_groups.each do |group_name, names|
    names.each do |ingredient_name|
      metadata = ingredient_metadata_for(
        ingredient_name,
        group_name
      )

      ingredient = Ingredient.find_by(
        "LOWER(name) = ?",
        ingredient_name.downcase
      )

      if ingredient.nil?
        Ingredient.create!(
          name: ingredient_name,
          ingredient_type: metadata[:ingredient_type],
          flavor_profiles: metadata[:flavor_profiles],
          user: nil
        )

        created_count += 1
      else
        ingredient.update!(
          ingredient_type: metadata[:ingredient_type],
          flavor_profiles: metadata[:flavor_profiles]
        )

        updated_count += 1
      end
    end
  end
end

puts "Created #{created_count} global ingredients."
puts "Updated #{updated_count} existing ingredients."

# =========================
# Categories
# =========================

category_definitions = [
  # Vodka
  {
    name: "Vodka",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Gin
  {
    name: "Gin",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Genever",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Rum
  {
    name: "Rum",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "White Rum",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Dark Rum",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Aged Rum",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Spiced Rum",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Overproof Rum",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Rhum Agricole",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Cachaca",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Agave
  {
    name: "Tequila",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Mezcal",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Whiskey / Whisky
  {
    name: "Whiskey",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Bourbon",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Rye",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Scotch",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Irish Whiskey",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Japanese Whisky",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Canadian Whisky",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Tennessee Whiskey",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Brandy
  {
    name: "Brandy",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Cognac",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Armagnac",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Calvados",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Pisco",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Grappa",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Asian Spirits
  {
    name: "Soju",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Shochu",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Sake",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Baijiu",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Liqueurs / Aperitifs
  {
    name: "Liqueur",
    alcoholic: true,
    ingredient_type: "Liqueur"
  },
  {
    name: "Amaro",
    alcoholic: true,
    ingredient_type: "Liqueur"
  },
  {
    name: "Aperitif",
    alcoholic: true,
    ingredient_type: "Liqueur"
  },
  {
    name: "Vermouth",
    alcoholic: true,
    ingredient_type: "Liqueur"
  },
  {
    name: "Absinthe",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Wine
  {
    name: "Wine",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Red Wine",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "White Wine",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Rose Wine",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Fortified Wine",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Port",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Sherry",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Madeira",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Marsala",
    alcoholic: true,
    ingredient_type: "Wine"
  },

  # Sparkling Wine
  {
    name: "Champagne",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Sparkling Wine",
    alcoholic: true,
    ingredient_type: "Wine"
  },
  {
    name: "Prosecco",
    alcoholic: true,
    ingredient_type: "Wine"
  },

  # Beer / Cider
  {
    name: "Beer",
    alcoholic: true,
    ingredient_type: "Beer"
  },
  {
    name: "Cider",
    alcoholic: true,
    ingredient_type: "Beer"
  },

  # Regional Spirits
  {
    name: "Aquavit",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Ouzo",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Raki",
    alcoholic: true,
    ingredient_type: "Spirit"
  },
  {
    name: "Arak",
    alcoholic: true,
    ingredient_type: "Spirit"
  },

  # Non-Alcoholic
  {
    name: "Nonalcoholic Spirit",
    alcoholic: false,
    ingredient_type: "Spirit"
  },
  {
    name: "Nonalcoholic Aperitif",
    alcoholic: false,
    ingredient_type: "Liqueur"
  },
  {
    name: "Nonalcoholic Vermouth",
    alcoholic: false,
    ingredient_type: "Liqueur"
  },
  {
    name: "Nonalcoholic Beer",
    alcoholic: false,
    ingredient_type: "Beer"
  },
  {
    name: "Nonalcoholic Sparkling Wine",
    alcoholic: false,
    ingredient_type: "Wine"
  }
].freeze


# =========================
# Seed Category Ingredients
# =========================

category_ingredient_created_count = 0

category_definitions.each do |definition|
  ingredient =
    Ingredient.find_by(
      "LOWER(name) = ?",
      definition[:name].downcase
    )

  next if ingredient

  Ingredient.create!(
    name: definition[:name],
    ingredient_type:
      definition[:ingredient_type],
    flavor_profiles: [],
    user: nil
  )

  category_ingredient_created_count += 1
end


# =========================
# Seed Categories
# =========================

category_created_count = 0
category_updated_count = 0

Category.transaction do
  category_definitions.each do |definition|
    ingredient =
      Ingredient.find_by!(
        "LOWER(name) = ?",
        definition[:name].downcase
      )

    category =
      Category.find_or_initialize_by(
        name: definition[:name]
      )

    if category.new_record?
      category_created_count += 1
    else
      category_updated_count += 1
    end

    category.alcoholic =
      definition[:alcoholic]

    category.ingredient =
      ingredient

    category.save!
  end
end


puts(
  "Created #{category_ingredient_created_count} missing category ingredients."
)

puts(
  "Created #{category_created_count} categories."
)

puts(
  "Updated #{category_updated_count} existing categories."
)
