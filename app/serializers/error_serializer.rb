class ErrorSerializer
  def self.format(record)
    {
      errors: record.errors.full_messages
    }
  end

  def self.forbidden_deletion
    {
      errors: [ "You are not authorized to delete this user" ]
    }
  end

  def self.forbidden_drink_modification
    {
      errors: [ "You are not authorized to modify this drink" ]
    }
  end

  def self.forbidden_recipe_modification
    {
      errors: [ "You are not authorized to modify this recipe" ]
    }
  end
end
