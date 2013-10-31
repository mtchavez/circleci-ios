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

  def self.verify_user
    defaults = NSUserDefaults.standardUserDefaults
    user = defaults['user']
    user = {} if user.nil? or user.empty?
    token = user['token']
    if token.nil? or token.empty?
      App.notification_center.post('CircleUnverifiedUser', nil)
    end
    circle = Circle.shared_instance
    circle.token = token
    circle.me do |me|
      alert_error unless me.is_a?(Me)
      if me.send(:valid?)
        Circle.shared_instance.verified = true
        App.notification_center.post('CircleVerifiedUser', nil)
      else
        user.delete('token')
        defaults['user'] = user
        defaults.synchronize
        App.notification_center.post('CircleUnverifiedUser', nil)
        Circle.shared_instance.verified = false
      end
    end
    return Circle.shared_instance.verified
  end

end
