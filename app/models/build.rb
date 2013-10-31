class Build

  BUILD_ATTRS = %w[status branch subject user build_num vcs_url]
  BUILD_ATTRS.each { |prop| attr_accessor prop }

  def initialize(attrs = {})
    attrs.each do |key, value|
      self.send("#{key.to_s}=", value) if BUILD_ATTRS.member? key
    end
  end

  def self.color_from_status(status)
    case status.to_s.downcase
    when 'error', 'failed', 'timedout' then '#FF3A2D'.to_color
    when 'started', 'running', 'queued' then '#34AADC'.to_color
    when 'canceled', 'no_tests', 'broken' then '#C7C7CC'.to_color
    when 'passed', 'success', 'fixed' then '#4CD964'.to_color
    else
      '#C7C7CC'.to_color
    end
  end

  def username
    user.nil? ? '' : user['login']
  end

  def gravatar(size=60)
    email = user ? user['email'] : ''
    gid = RmDigest::MD5.hexdigest email.to_s.downcase
    "http://www.gravatar.com/avatar/#{gid}?s=#{size}"
  end

  def status_color
    Build.color_from_status status.to_s.downcase
  end

  def repo_name
    vcs_url.to_s.gsub('https://github.com/', '')
  end

  def cache_gravatar!
    gurl = gravatar
    gimage = Circle.cached gurl
    return gimage if gimage
    image_data = NSData.dataWithContentsOfURL NSURL.URLWithString(gurl)
    gimage = UIImage.imageWithData image_data
    Circle.cache! gurl, gimage
    return gimage
  end

end
