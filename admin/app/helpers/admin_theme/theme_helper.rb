#--- mapping for common icons - (keep at top level, do not place inside a module)
#------------------------------------------------------------------------------
CommonIcons = {
  add:              'fa fa-plus fa-fw',
  blogs:            'fa fa-paragraph fa-fw',
  calendar:         'fa fa-calendar fa-fw',
  cancel:           'fa fa-times-circle-o fa-fw',
  caret_down:       'fa fa-caret-down',
  chat:             'fa fa-commenting-o fa-fw',
  check:            'fa fa-check fa-fw',
  checkmark:        'fa fa-check fa-fw',
  close:            'fa fa-times-circle-o fa-fw',
  cog:              'fa fa-cog fa-fw',
  cogs:             'fa fa-cogs fa-fw',
  collapse_button:  'fa fa-chevron-down fa-fw',
  comment:          'fa fa-comment-o fa-fw',
  comments:         'fa fa-comments-o fa-fw',
  courses:          'fa fa-book fa-fw',
  dashboard:        'fa fa-desktop fa-fw',
  delete:           'fa fa-trash-o fa-fw',
  edit:             'fa fa-pencil fa-fw',
  events:           'fa fa-calendar fa-fw',
  exit:             'fa fa-sign-out fa-fw',
  facebook:         'fa fa-facebook fa-fw',
  forums:           'fa fa-comments-o fa-fw',
  gear:             'fa fa-cog fa-fw',
  gears:            'fa fa-cogs fa-fw',
  globe:            'fa fa-globe fa-fw',
  help:             'fa fa-question fa-fw',
  image:            'fa fa-picture-o fa-fw',
  lexicon:          'fa fa-briefcase fa-fw',
  lock:             'fa fa-lock fa-fw',
  mail:             'fa fa-envelope-o fa-fw',
  mail_open:        'fa fa-envelope-open-o fa-fw',
  media_library:    'fa fa-camera fa-fw',
  money:            'fa fa-money fa-fw',
  new:              'fa fa-plus fa-fw',
  newsletters:      'fa fa-envelope fa-fw',
  pages:            'fa fa-align-left fa-fw',
  private:          'fa fa-lock fa-fw',
  protected:        'fa fa-unlock-alt fa-fw',
  public:           'fa fa-globe fa-fw',
  refresh:          'fa fa-refresh fa-fw',
  social_media:     'fa fa-facebook fa-fw',
  subscriptions:    'fa fa-money fa-fw',
  tag:              'fa fa-tag fa-fw',
  tags:             'fa fa-tags fa-fw',
  text:             'fa fa-align-left fa-fw',
  trash:            'fa fa-trash-o fa-fw',
  undo:             'fa fa-undo fa-fw',
  user:             'fa fa-user fa-fw',
  users:            'fa fa-users fa-fw',
  view:             'fa fa-search fa-fw',
  wrench:           'fa fa-wrench fa-fw'
}.freeze

module AdminTheme
  module ThemeHelper

    #------------------------------------------------------------------------------
    def subsection(options = {}, &block)
      content   = block_given? ? capture(&block) : ''
      title     = ''.html_safe
      title     << (content_tag(:i, '', class: options[:icon]) + ' ') if options[:icon]
      title     << options[:title]
      title     << (content_tag(:small, options[:subtitle], style: 'display: block;')) if options[:subtitle]

      content_tag(:div, content_tag(:h5, title) + content, class: 'subsection', id: options[:id])
    end

    # Statistics block
    # -- Usage in Page Header:
    #   <ul class="page-stats">
    #     <li><%= stat_block_small label: 'Usable Funds', number: humanized_money_with_symbol(amount_cents_since_launch),
    #                 percent: amount_percent.round, color_type: :success, icon: 'icon-coin', url: '#' %></li>
    #   </ul>
    #
    # -- Usage in a sidebar, in a linear style
    #     <ul class="statistics statistics-small statistics-linear">
    #       <li><%= stat_block_small label: 'Total Funds', number: total_money.format(no_cents_if_whole: true),
    #               color_type: :info, icon: 'icon-coin', percent: 100 %></li>
    #     </ul>
    #
    # -- Usage standard, centered across width
    #     <ul class="statistics">
    #       <li><%= stat_block_small label: 'Usable Funds', number: humanized_money_with_symbol(amount_cents_since_launch),
    #                   percent: amount_percent.round, color_type: :success, icon: 'icon-coin', url: '#' %></li>
    #       <li><%= stat_block_small label: 'Estimated VAT', number: humanized_money_with_symbol(tax_cents_since_launch),
    #                   percent: (100 - amount_percent).round, color_type: :danger, icon: 'icon-coin', url: '#' %></li>
    #       <li><%= stat_block_small label: 'Total Collected', number: humanized_money_with_symbol(total_cents_since_launch),
    #                   percent: 100, color_type: :info, icon: 'icon-coin', url: '#' %></li>
    #     </ul>

    #------------------------------------------------------------------------------
    def stat_block_small(options = {label: 'User Registrations', number: '1,245', url: '#', color_type: :success, icon: 'fa fa-user', percent: 80})
      info = content_tag :div, class: 'statistics-info' do
        concat(link_to icons(options[:icon]), options[:url], title: options[:label], class: "badge badge-#{options[:color_type].to_s}")
        concat(content_tag :strong, options[:number])
      end
      progress_bar = content_tag(:div, class: 'progress progress-micro') do
        content_tag(:div, class: "progress-bar progress-bar-#{options[:color_type].to_s}", role: 'progressbar',
                          aria: {valuenow: options[:percent], valuemin: '0', valuemax: '100'}, style: "width: #{options[:percent]}%") do
            content_tag(:span, "#{options[:percent]}% Complete", class: 'sr-only')
        end
      end
      info + progress_bar + content_tag(:span, options[:label])
    end

    # Create a title and number, followed by a small sparkline graph
    # -- Usage
    #   <ul class="page-stats">
    #     <li><%= stat_with_graph title: 'Visits', number: '10,320', color_type: :info, data_list: '10,14,8,45' %></li>
    #   </ul>
    #   <ul class="page-stats list-justified">
    #     <li class="bg-default">
    #       <%= stat_with_graph title: 'Visits', number: '10,320', color_type: :info, data_list: '10,14,8,45' %>
    #     </li>
    #   </ul>
    #------------------------------------------------------------------------------
    def stat_with_graph(options = {title: 'Page Visits', number: '21,252', color_type: :success, data_list: '12, 30, 8, 5, 10'})
      title_section = content_tag :div, class: 'page-stats-showcase' do
        content_tag(:span, options[:title]) +
        content_tag(:h2, options[:number])
      end
      bar_section = content_tag :div, options[:data_list], class: "bar-#{options[:color_type].to_s} chart pull-right"
      title_section + bar_section
    end

    # output a slim horizontal progress bar, with a label, value text, percentage,
    # and color (such as info, success, pending, etc)
    #------------------------------------------------------------------------------
    def slim_progress_bar(options = {})
      #--- if no label specified, value will not get displayed properly
      options[:label] = '&nbsp;'.html_safe if (options[:label].blank? && options[:value])

      render(:partial => 'admin_theme/shared/slim_progress_bar',
             :locals => { label: options[:label],
                          value: options[:value].to_s,
                          color: (options[:color] || 'info'),
                          percentage: options[:percentage].to_i,
                          bottom_label: options[:bottom_label]})
    end


  end
end