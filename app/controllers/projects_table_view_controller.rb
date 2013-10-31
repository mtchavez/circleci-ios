class ProjectsTableViewController < UITableViewController

  attr_accessor :projects

  def viewDidLoad
    super
    self.refreshControl.addTarget(self, action: 'refresh', forControlEvents: UIControlEventValueChanged)
    defaults = NSUserDefaults.standardUserDefaults
    bg_img = UIImage.imageNamed 'cream_dust.png'
    self.view.backgroundColor = UIColor.colorWithPatternImage bg_img
    user = defaults['user']
    refresh if user and user['token']
    @projects = Hash.new []
  end

  def viewDidUnload
    super
  end

  def load_projects
    @projects = Hash.new []
    defaults = NSUserDefaults.standardUserDefaults
    user = defaults['user']
    circle = Circle.shared_instance
    circle.token ||= user['token']
    all_projects = []
    circle.all_projects do |projs|
      next if projs.nil? or projs.empty?
      if projs == ['unauthorized']
         self.refreshControl.endRefreshing
         view.reloadData
         break
      end
      all_projects = projs.dup
      all_projects.each do |proj|
        all_branches = ['master'] + proj.all_branches.take(5)
        all_branches.uniq.each do |branch|
          branch_info = proj.branches[branch]
          next if branch_info['recent_builds'].to_a.empty?
          branch_info.merge!('name' => branch)
          attrs = Project::PROJ_ATTRS.inject({}) { |hash, attr| hash[attr] = proj.send(attr); hash }
          proj = Project.new attrs.merge('branch_info' => branch_info)
          @projects[proj.repo_name] += [proj]
        end
      end
      self.refreshControl.endRefreshing
      view.reloadData
    end
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

## Table view data source

  def numberOfSectionsInTableView(tableView)
    @projects.keys.size
  end

  def tableView(tableView, numberOfRowsInSection:section)
    key = @projects.keys[section]
    @projects[key].size
  end

  def tableView(tableView, titleForHeaderInSection:section)
    @projects.keys[section]
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cellIdentifier = 'ProjectCell'
    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) || begin
      cell = ProjectViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier: cellIdentifier
      cell
    end

    section, row = indexPath.section, indexPath.row
    key = @projects.keys[section]
    projects = @projects[key]
    project = projects[row]
    cell.branch_label.text = project.branch_name
    cell.setup_build_views(project)
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
    load_projects
   end

end
