Themenap::Config.configure do |c|
  c.server = 'https://ada.edu.au'
  c.use_basic_auth = true
  c.snippets =
    [ { :css  => 'title',
        :text => '<%= yield :title %>'
      },
      { :css  => 'head',
        :text => '<%= render "layouts/css_includes" %><%= csrf_meta_tag %>',
        :mode => :append
      },
      { :css  => 'meta[name=csrf-param]',
        :mode => :remove
      },
      { :css  => 'meta[name=csrf-token]',
        :mode => :remove
      },
      { :css  => 'body',
        :mode => :setattr,
        :key => 'class',
        :value => 'default'
      },
      { :css  => 'html',
        :text => '<%= render "layouts/js_includes" %>',
        :mode => :append
      },
      { :css => 'nav.archive_menu',
        :mode => :remove
      },
      { :css  => 'article',
        :text => '<%= render "layouts/body" %>'
      },
      { :css  => 'nav.subnav',
        :text => '<%= render "layouts/links" %>'
      },
      { :css  => 'nav.breadcrumbs',
        :text => '<%= render "layouts/breadcrumbs" %>',
        :mode => :replace
      },
      { :css  => '.login',
        :text => '<%= render "layouts/login" %>'
      } ]
  c.layout_name = 'ada'
end
