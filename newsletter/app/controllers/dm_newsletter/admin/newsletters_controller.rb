class DmNewsletter::Admin::NewslettersController < DmNewsletter::Admin::AdminController
  include DmNewsletter::PermittedParams

  #before_filter   :mailchimp_guard,   only:   [:new, :edit, :create, :update]
  before_filter   :newsletter_lookup, except: [:index, :new, :create, :synchronize_lists]

  #------------------------------------------------------------------------------
  def index
    @newsletters = using_mailchimp? ? MailchimpNewsletter.all : StandardNewsletter.all
    @newsletters.each { |newsletter| newsletter.update_list_stats }
  end

  #------------------------------------------------------------------------------
  def new
    @newsletter = using_mailchimp? ? MailchimpNewsletter.new : StandardNewsletter.new
  end

  #------------------------------------------------------------------------------
  def edit
  end

  #------------------------------------------------------------------------------
  def create
    @newsletter = using_mailchimp? ? MailchimpNewsletter.new(mailchimp_newsletter_params) : StandardNewsletter.new(standard_newsletter_params)
    if @newsletter.save
      redirect_to admin_newsletters_url, notice: 'Newsletter was successfully created.'
    else
      render action: :new
    end
  end

  #------------------------------------------------------------------------------
  def update
    if @newsletter.update_attributes(newsletter_params)
      redirect_to admin_newsletters_url, notice: 'Newsletter was successfully updated.'
    else
      render action: :edit
    end
  end

  #------------------------------------------------------------------------------
  def destroy
    @newsletter.destroy

    redirect_to admin_newsletters_url
  end

  #------------------------------------------------------------------------------
  def show
    # @subscriptions  = @newsletter.subscriptions
    @folder_list = @newsletter.folder_list
  end
  
  #------------------------------------------------------------------------------
  def synchronize_lists
    if using_mailchimp?
      MailchimpNewsletter.synchronize
      redirect_to(admin_newsletters_url, notice: 'Synchronized with Mailchimp') and return
    else
      redirect_to(admin_newsletters_url) and return
    end
  end
  
private

  #------------------------------------------------------------------------------
  def newsletter_lookup
    @newsletter = Newsletter.find(params[:id])
  end
  
  # Protects certain actions from being run if we're using mailchimp integration
  #------------------------------------------------------------------------------
  def mailchimp_guard
    if using_mailchimp?
      redirect_to(admin_newsletters_url, error: 'Action not supported when using Mailchimp') and return false
    else
      true
    end
  end

end
