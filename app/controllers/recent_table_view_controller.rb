class RecentTableViewController < UITableViewController

  attr_accessor :builds

  def viewDidLoad
    super
    self.refreshControl.addTarget(self, action: 'refresh', forControlEvents: UIControlEventValueChanged)
    bg_img = UIImage.imageNamed 'cream_dust.png'
    self.view.backgroundColor = UIColor.colorWithPatternImage bg_img
    add_observers
    Me.verify_user
    @builds = []
  end

  def viewDidUnload
    super
    App.notification_center.unobserve 'CircleVerifiedUser'
    App.notification_center.unobserve 'CircleUnverifiedUser'
  end

  def add_observers
    App.notification_center.observe 'CircleVerifiedUser' do |notification|
      get_builds(notification.object)
    end

    App.notification_center.observe 'CircleUnverifiedUser' do |notification|
      show_login(notification.object)
    end
  end

  def get_builds(sender)
    refresh
  end

  def show_login(sender)
    loginView = LoginViewController.new.initWithNibName 'LoginView', bundle: nil
    loginView.delegate = self
    self.tabBarController.presentViewController(loginView, animated:false, completion:nil)
  end

  def load_recent_builds
    defaults = NSUserDefaults.standardUserDefaults
    user = defaults['user']
    circle = Circle.shared_instance
    circle.token ||= user['token']
    circle.recent_builds do |builds|
      if builds == ['unauthorized']
        @builds = []
      else
        @builds = builds.dup
      end
      self.refreshControl.endRefreshing
      view.reloadData
    end
  end

  def viewDidAppear(animated)
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

## Table view data source

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @builds.to_a.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cellIdentifier = 'BuildCell'
    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) || begin
      cell = BuildViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier: cellIdentifier
      cell
    end

    build = @builds[indexPath.row]
    cell.build_label.text = build.repo_name
    cell.status_view.backgroundColor = build.status_color
    cell.subject_label.text = build.subject.to_s
    cell.committer_label.text = build.username
    gimage = Circle.cached build.gravatar(60)
    gimage = build.cache_gravatar! unless gimage
    cell.avatar_view.image = gimage
    cell.selectionStyle = UITableViewCellSelectionStyleNone
    cell
  end


## Table view delegate

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    # Navigation logic may go here. Create and push another view controller.
    # detailViewController = DetailViewController.alloc.initWithNibName("Nib name", bundle:nil)
    # Pass the selected object to the new view controller.
    # self.navigationController.pushViewController(detailViewController, animated:true)
  end

## Refresh Control Actions

  def refresh
    self.refreshControl.beginRefreshing
    load_recent_builds
  end

end
