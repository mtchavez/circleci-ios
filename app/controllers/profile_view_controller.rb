class ProfileViewController < UIViewController

  extend IB

  outlet :profile_image_view
  outlet :email_label
  outlet :token_label

  def viewDidLoad
    super
    # Do any additional setup after loading the view.
  end

  def viewDidUnload
    super
    # Release any retained subviews of the main view.
  end

  def viewWillAppear(animated)
    defaults = NSUserDefaults.standardUserDefaults
    user = defaults['user']
    email_label.text = "#{user['email']}"

    if Circle.shared_instance.verified
      token_label.text = "#{user['token']}"
    else
      token_label.text = "UNVERIFIED TOKEN"
    end
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

end
