class UserSerializer
  def self.format(user)
    {
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email
    }
  end

  def self.created(user)
    {
      username: user.username,
      email: user.email
    }
  end

  def self.all_users(users)
    users.map do |user|
      format(user)
    end
  end
end
