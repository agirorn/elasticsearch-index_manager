class Hash
  def stringify_keys_and_symbol_values_recursively!
    self.keys.each do |key|
      value = self[key]
      value = value.to_s if value.is_a? Symbol
      if value.respond_to? :stringify_keys_and_symbol_values_recursively!
        value.stringify_keys_and_symbol_values_recursively!
      end

      if key.is_a? Symbol
        self.delete(key)
      end

      key = key.to_s
      self[key] = value
    end

    return self
  end
end
