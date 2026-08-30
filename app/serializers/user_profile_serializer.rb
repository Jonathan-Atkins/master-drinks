class UserProfileSerializer
  def self.format(user, current_user)
    {
      id: user.id,
      username: user.username,

      drink_count:
        user
          .drinks
          .publicly_visible
          .count,

      recipe_count:
        user
          .owned_recipes
          .publicly_visible
          .joins(:drink)
          .where(
            drinks: {
              publicly_visible: true
            }
          )
          .count,

      is_current_user:
        user.id == current_user.id
    }
  end
end
