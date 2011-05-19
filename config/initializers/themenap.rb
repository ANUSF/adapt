Themenap::Config.configure do |c|
  c.server = 'https://test.ada.edu.au'
  c.use_basic_auth = true
  c.snippets =
    [ { :css => 'title',
        :text => '<%= yield :title %>' },
      { :css => 'head',
        :text => '<%= render "layouts/css_includes" %>',
        :mode => :append },
      { :css => 'body',
        :mode => :setattr, :key => 'class', :value => 'social_science' },
      { :css => 'html',
        :text => '<%= render "layouts/js_includes" %>',
        :mode => :append },
      { :css => 'article',
        :text => '<%= render "layouts/body" %>' },
      { :css => 'nav.subnav',
        :text => '<%= render "layouts/links" %>' },
      { :css => '.login',
        :text => '<%= render "layouts/login" %>' } ]
  c.layout_name = 'ada'
end
