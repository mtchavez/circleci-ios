class Circle

  BASE_URI = 'https://circleci.com/api/v1'

  attr_accessor :token, :cached_images, :verified

  def initialize
    @token = nil
    @verified = false
  end

  def self.shared_instance
    @shared ||= Circle.new
  end

  def default_headers
    { 'accept' => 'application/json', 'content-type' => 'application/json' }
  end

  def me(&block)
    url = "#{BASE_URI}/me?circle-token=#{@token}"
    BW::HTTP.get(url, { :headers => default_headers }) do |response|
      result_data = BW::JSON.parse(response.body.to_str) rescue nil
      result_data = {} if result_data.nil? or result_data.empty?
      result_data.merge!({'token' => @token})
      block.call Me.new(result_data)
    end
  end

  def recent_builds(&block)
    url = "#{BASE_URI}/recent-builds?circle-token=#{@token}"
    BW::HTTP.get(url, { :headers => default_headers }) do |response|
      result_data = BW::JSON.parse(response.body.to_str) rescue nil
      result_data = [] if result_data.nil? or result_data.empty?
      if result_data.is_a?(Hash) and result_data['message'].match(/login|log in/i)
        Circle.shared_instance.verified = false
        block.call ['unauthorized']
      else
        block.call result_data.map { |attrs| Build.new attrs }
      end
    end
  end

  def all_projects(&block)
    url = "#{BASE_URI}/projects?circle-token=#{@token}"
    BW::HTTP.get(url, { :headers => default_headers }) do |response|
      result_data = BW::JSON.parse(response.body.to_str) rescue nil
      result_data = [] if result_data.nil? or result_data.empty?
      if result_data.is_a?(Hash) and result_data['message'].match(/login|log in/i)
        Circle.shared_instance.verified = false
        block.call ['unauthorized']
      else
        block.call result_data.map { |attrs| Project.new attrs }
      end
    end
  end

  def self.cached_gravatars
    @cached_images ||= {}
  end

  def self.cache!(key, image)
    cached_gravatars[key] = image
  end

  def self.cached(key)
    cached_gravatars[key]
  end

end
