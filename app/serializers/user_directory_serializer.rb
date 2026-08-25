class UserDirectorySerializer
  def self.format(user)
    {
      id: user.id,
      username: user.username,
      drink_count: user.drinks.count,
      recipe_count: user.owned_recipes.count
    }
  end

  def self.format_collection(users)
    users.map do |user|
      format(user)
    end
  end
end
