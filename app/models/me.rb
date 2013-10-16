class Me

  ME_ATTRS = %w[login selected_email token gravatar_id]
  ME_ATTRS.each { |prop| attr_accessor prop }

  def initialize(attrs = {})
    attrs.each do |key, value|
      self.send("#{key.to_s}=", value) if ME_ATTRS.member? key
    end
    self.valid? ? self : nil
  end

  def valid?
    if token.nil? or token.empty? or login.nil? or login.empty?
      false
    else
      true
    end
  end

end
