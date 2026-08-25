class UserProfileSerializer
  def self.format(user)
    {
      id: user.id,
      username: user.username,
      drink_count: user.drinks.count,
      recipe_count: user.owned_recipes.count
    }
  end
end
