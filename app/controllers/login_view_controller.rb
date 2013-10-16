class LoginViewController < UIViewController

  extend IB

  attr_accessor :delegate

  outlet :input_field
  outlet :sign_in_btn, UIButton

  def viewDidLoad
    super
    # Do any additional setup after loading the view.

    input_field.delegate = self
    input_field.setReturnKeyType UIReturnKeyDone
    input_field.addTarget(self,
                  action:'textFieldFinished:',
        forControlEvents:UIControlEventEditingDidEndOnExit)

    sign_in_btn.layer.setCornerRadius 9.0
    sign_in_btn.layer.setMasksToBounds true
    sign_in_btn.layer.setBorderWidth 1.0
    sign_in_btn.layer.setBorderColor UIColor.clearColor.CGColor
    sign_in_btn.backgroundColor = '#4CD964'.to_color
    self.view.when_tapped do
      if self.input_field.isFirstResponder
        self.input_field.resignFirstResponder
      end
    end
  end

  def viewDidUnload
    super
    # Release any retained subviews of the main view.
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

  def sign_in(sender)
    circle = Circle.shared_instance
    circle.token = input_field.text
    circle.me do |me|
      alert_error unless me.is_a?(Me)
      if me.send(:valid?)
        defaults = NSUserDefaults.standardUserDefaults
        defaults['user'] ||= {}
        defaults['user'] = defaults['user'].merge({'token' => me.token, 'email' => me.selected_email, 'login' => me.login})
        defaults.synchronize
        self.delegate.dismissViewControllerAnimated:true, completion: nil
        self.delegate.refresh
      else
        alert_error
      end
    end
  end

  def alert_error
    title = 'Authentication Failed'
    message = 'Please make sure your token is valid and try again.'
    alert = UIAlertView.new
    alert.title = title
    alert.message = message
    alert.delegate = self
    alert.addButtonWithTitle 'OK'
    alert.show
  end

  def textFieldShouldReturn(text_field)
    if text_field.isFirstResponder
      text_field.resignFirstResponder
    end
  end

  def textFieldFinished(sender)
    if text_field.isFirstResponder
      text_field.resignFirstResponder
    end
  end

  def textView(textView, shouldChangeTextInRange:range , replacementText:text)
    print text
    if text == '\n'
      textView.resignFirstResponder
      return false
    end
    true
  end

end
