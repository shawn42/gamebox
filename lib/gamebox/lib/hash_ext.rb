class Hash
  def symbolize_keys
    inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end

  def slice(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end
end

