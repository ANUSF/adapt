Themenap::Config.active = ! ADAPT::CONFIG['adapt.theme.old']
Themenap::Config.server = 'http://testada'
Themenap::Config.snippets =
  [ { :css => 'title',
      :text => '<%= yield :title %>' },
    { :css => 'head',
      :text => '<%= render "layouts/css_includes" %>',
      :mode => :append },
    { :css => 'body',
      :mode => :setattr, :key => 'id', :value => 'social_science' },
    { :css => 'html',
      :text => '<%= render "layouts/js_includes" %>',
      :mode => :append },
    { :css => 'article',
      :text => '<%= render "layouts/body" %>' },
    { :css => 'nav.subnav',
      :text => '<%= render "layouts/links" %>' },
    { :css => '.login',
      :text => '<%= render "layouts/login" %>' } ]
Themenap::Config.layout_name = 'ada'
