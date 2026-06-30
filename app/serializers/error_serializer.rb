class ErrorSerializer
  def self.format(record)
    {
      errors: record.errors.full_messages
    }
  end

  def self.forbidden_deletion
    {
      errors: [ "You are not authorized to delete this user" ],
      status: :forbidden
    }
  end

  def self.forbidden_drink_modification
    {
      errors: [ "You are not authorized to modify this drink" ]
    }
  end
end
