Themenap::Config.active = ! ADAPT::CONFIG['adapt.theme.old']
Themenap::Config.server = 'http://testada'
Themenap::Config.snippets =
  [ { :css => 'title',
      :text => '<%= yield :title %>' },
    { :css => 'head',
      :text => '<%= render "layouts/includes" %>',
      :mode => :append },
    { :css => 'body',
      :text => 'social_science',
      :mode => :set_id },
    { :css => 'article',
      :text => '<%= render "layouts/body" %>' },
    { :css => 'nav.subnav',
      :text => '<%= render "layouts/links" %>' },
    { :css => '.login',
      :text => '<%= render "layouts/login" %>' } ]
Themenap::Config.layout_name = 'ada'
