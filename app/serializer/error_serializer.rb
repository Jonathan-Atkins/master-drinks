class ErrorSerializer
  def self.format(record)
    {
      errors: record.errors.full_messages
    }
  end
end