(function(){var a,b,c,d;a=jQuery,b={header:"> ul",entry:"> ul > li",body:"> div",link:"> a"},d=function(){var c,d,e,f,g,h;return f=a(this).attr("href"),g=a(f),c=a(g.data("container")),d=c.data("options")||{},e=c.data("patterns")||b,h=d.currentTabClass||"current-tab",c.find(e.body).css({display:"none"}),g.css({display:"block"}),c.find(e.entry).find(e.link).removeClass(h).filter("[href="+f+"]").addClass(h),g.trigger("tab-opened"),!1},c=function(){var b,c;return c=a(this).find("a"),b=a(c.attr("href")),a.each(arguments,function(a,d){if(b.find("."+d).size()>0)return c.addClass(d)})},a.fn.extend({tabContainer:function(e){var f,g;return e==null&&(e={}),g=e.tagsToPropagate||[],f={},a.extend(f,b),a.extend(f,e.patterns||{}),this.each(function(){var b;return b=a(this),b.data("options",e),b.data("patterns",f),b.find(f.body).data("container",this),b.find(f.header).css({display:"block"}),b.find(f.entry).each(c,g).find(f.link).click(d).first().each(d)})},tabSelect:function(){return this.each(d)},tabLink:function(){return this.click(d)}})}).call(this)