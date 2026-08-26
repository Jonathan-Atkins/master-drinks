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
      id: user.id,
      username: user.username,
      email: user.email
    }
  end
end