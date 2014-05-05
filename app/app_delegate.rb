class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible

    if Twitter::Composer.available?
      Twitter.sign_in do |granted, ns_error|
        if granted
          puts "Twitter ID #{Twitter.accounts[0].user_id}"
          @defaults = NSUserDefaults.standardUserDefaults
          @defaults["twitter_id"] = Twitter.accounts[0].user_id
          
          exo_facts_controller = ExoFactsController.alloc.initWithNibName(nil, bundle: nil)
          geo_cache_controller = GeoCachingController.alloc.initWithNibName(nil, bundle: nil)
          @visited_sites_controller = VisitedSitesController.alloc.initWithNibName(nil, bundle: nil)
          @visited_nav_controller = UINavigationController.alloc.initWithRootViewController(@visited_sites_controller)
          adler_controller = AdlerInfoController.alloc.initWithNibName(nil, bundle: nil)

          tab_controller = UITabBarController.alloc.initWithNibName(nil, bundle: nil)
          tab_controller.viewControllers = [exo_facts_controller, geo_cache_controller, @visited_nav_controller, adler_controller]

          @window.rootViewController = tab_controller
        else
          label = UILabel.alloc.initWithFrame(CGRectZero)
          @window.backgroundColor = UIColor.whiteColor
          label.text = "Please allow access to Twitter in settings"
          label.sizeToFit
          label.center = CGPointMake(@window.frame.size.width / 2, @window.frame.size.height / 2)
          @window.addSubview(label)
        end
      end
    else
      label = UILabel.alloc.initWithFrame(CGRectZero)
      @window.backgroundColor = UIColor.whiteColor
      label.text = "Login to Twitter in your settings!"
      label.sizeToFit
      label.center = CGPointMake(@window.frame.size.width / 2, @window.frame.size.height / 2)
      @window.addSubview(label)
    end
    true
  end
end

class ReverseAuth

  def getData
    url = NSURL.URLWithString "https://api.twitter.com/oauth/request_token"
    dict = {x_auth_mode: "reverse_auth"}
    @step1Request = TWSignedRequest.alloc.initWithURL(url, parameters: dict, requestMethod: TWSignedRequestMethodPOST)
    @step1Request.consumerKey = 'CONSUMER_KEY'
    @step1Request.consumerSecret = 'CONSUMER_SECRET'
    Dispatch::Queue.concurrent.async do
      @step1Request.performRequestWithHandler(->(data, resp, err){
        Dispatch::Queue.main.async do
          setData(data)
        end
      })
    end
  end

  def setData(data)
    puts "This is the return data: #{data.inspect}"
  end

end

class Twitter::User
  def user_id
    self.ac_account.valueForKeyPath("properties")["user_id"]
  end
end
