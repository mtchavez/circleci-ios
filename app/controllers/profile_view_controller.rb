class ProfileViewController < UIViewController

  extend IB

  outlet :profile_image_view
  outlet :email_label
  outlet :token_label

  def viewDidLoad
    super
    # Do any additional setup after loading the view.
    defaults = NSUserDefaults.standardUserDefaults
    user = defaults['user']
    email_label.text = "#{user['email']}"
    token_label.text = "#{user['token']}"
  end

  def viewDidUnload
    super
    # Release any retained subviews of the main view.
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

end
