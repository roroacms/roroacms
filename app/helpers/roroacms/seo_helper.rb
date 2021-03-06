module Roroacms 
  module SeoHelper

    @seo_title = ''
    @seo_description = ''

    # Returns a block of html with all the necessary headers for the front end html to include.
    # this is for the SEO functionallity to be included on each page. get_meta_headers is a
    # bootstrap to include all of the necessary functions

    def get_meta_headers

      headtags = ''

      # decide wether it is a page or it is a template displying other content i.e. the category page

      if !@content.nil?


        # if it has ACTUAL content then generate meta from the page content
        if !(@content.respond_to? :length)

          home_id = Setting.get('home_page')

          if @content.id == home_id.to_f
            # if it is the homepage create the meta tags manually
            headtags = get_manual_metadata 'home'
          else
            # use the page content to generate the meta data
            if @content.post_seo_is_disabled != 'Y'
              headtags = "#{get_page_title}\n"
              headtags += "#{get_meta_description}\n"
              headtags += "#{get_google_analytics}\n"
              headtags += "#{get_robots_tag}"
              headtags += "#{canonical_urls}"
            end
          end

          render :inline => headtags

        else

          url_arr = params[:slug].split('/') if !params[:slug].nil?

          # get generic variables
          article_url = Setting.get('articles_slug')
          category_url = Setting.get('category_slug')

          # if the url is equal to the article, category or archive area
          if (!url_arr.blank? && (url_arr.last == article_url || url_arr.last.match(/\A\+?\d+(?:\.\d+)?\Z/) || url_arr[1] == category_url))
            last_url = url_arr.last
            robots_var = nil

            if url_arr[0] == article_url || url_arr[1] == category_url
              robots_var = 'category'
            elsif last_url.match(/\A\+?\d+(?:\.\d+)?\Z/)
              robots_var = 'archive'
            end

            new_string = last_url.slice(0,1).capitalize + last_url.slice(1..-1)

            if last_url.match(/\A\+?\d+(?:\.\d+)?\Z/)
              if !url_arr[2].blank?

                new_string = Date::MONTHNAMES[url_arr[2].to_i]
                new_string = "#{new_string} #{url_arr[1]}"

                if !url_arr[3].blank?
                  new_string = "#{url_arr[3]} #{new_string}"
                end

              end
            end

            headtags = "#{get_page_title new_string}\n"
            headtags += "#{get_google_analytics}\n"
            headtags += "#{get_robots_tag robots_var}"

            render :inline => headtags

          end

        end

      else

        # render the 404 meta data
        headtags = response.status == 404 ? get_manual_metadata('404') : application_set_headers
        render :inline => headtags

      end

    end

    private


    # returns the description meta tag. It will return a truncated version of the content if nothing is given and it does not have an seo description
    # Params:
    # +override+:: override the content with the data provided

    def get_meta_description(overide = nil)

      # if override has content, use this content to create the meta description

      if !overide.nil?
        return "<meta name=\"description\" content=\"#{override}\" />\n<meta name=\"author\" content=\"#{Setting.get('seo_site_title')}\">"
      else
        # if seo description is not blank then use that
        if !@content.post_seo_description.blank?
          return "<meta name=\"description\" content=\"#{@content.post_seo_description}\" />\n<meta name=\"author\" content=\"#{Setting.get('seo_site_title')}\">"
        elsif Setting.get('seo_autogenerate_descriptions') == 'Y'
          # if worst comes to worst use the page content
          description = truncate(prep_content(@content), :length => 100, :separator => ' ').gsub(/\r?\n|\r/, "")
          return "<meta name=\"description\" content=\"#{strip_tags(description)}\" />\n<meta name=\"author\" content=\"#{Setting.get('seo_site_title')}\">"
        end
      end

      return ''

    end


    # returns the page title meta tag. It will return the post content title if nothing is given via override and it does not have an seo title
    # Params:
    # +override+:: override the content with the data provided

    def get_page_title(overide = nil)
      
      # if override has content, use this content to create the meta title


      if !overide.blank?

        websiteTitle = Setting.get('seo_site_title')
        title = "#{overide} | #{websiteTitle}"
        @seo_title =  "<title>#{title}</title>"

      else

        # if seo title is not blank then use that
        if !@content.post_seo_title.blank?
          @seo_title = "<title>#{@content.post_seo_title}</title>"
        else
          # if worst comes to worst use the page title
          websiteTitle = Setting.get('seo_site_title')
          title = "#{@content.post_title} | #{websiteTitle}"
          @seo_title = "<title>#{title}</title>"
        end

      end

    end


    # returns the page robots meta tag. The setting being compared are both set to N by default
    # Params:
    # +override+:: override the content with the data provided


    def get_robots_tag(overide = nil)

      if !overide.blank?
        # if you use override the system will use the generic settings

        if overide == 'archive' && Setting.get('seo_no_index_archives')	== 'Y'
          ret = "<meta name=\"robots\" content=\"noindex, follow\" />"
        elsif overide == 'category' && Setting.get('seo_no_index_categories') == 'Y'
          ret = "<meta name=\"robots\" content=\"noindex, follow\" />"
        end

      else

        if @content.post_seo_no_index == 'Y' && @content.post_seo_no_follow == 'Y'
          ret = "<meta name=\"robots\" content=\"noindex, nofollow\" />"
        elsif @content.post_seo_no_index == 'N' && @content.post_seo_no_follow == 'Y'
          ret = "<meta name=\"robots\" content=\"index, nofollow\" />"
        elsif @content.post_seo_no_index == 'Y' && @content.post_seo_no_follow == 'N'
          ret = "<meta name=\"robots\" content=\"noindex, follow\" />"
        end

      end

      ret

    end


    # returns all the meta data for a given type
    # Params:
    # +type+:: type of settings that you want from the admin panel, this only works with the home settings currently

    def get_manual_metadata(type)

      title = "seo_#{type}_title"
      description = "seo_#{type}_description"

      headtags = "<title>#{Setting.get(title)}</title>\n"
      headtags += "<meta name=\"description\" content=\"#{Setting.get(description)}\" />\n"
      headtags += "#{get_google_analytics}\n"
      headtags += "#{canonical_urls}"

      headtags

    end

    def application_set_headers
      headtags = "<title>#{@seo_title} | #{Setting.get('seo_site_title')}</title>\n"
      headtags += "<meta name=\"description\" content=\"#{@seo_description}\" />\n"
      headtags += "#{get_google_analytics}\n"
      headtags += "#{canonical_urls}"
      headtags
    end

    # returns the google analytics code with the given UI tracking code that you set in the admin settings

    def get_google_analytics

      analyticsID = Setting.get('seo_google_analytics_code')
      if !analyticsID.blank?

        analyticsCode = "<script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '#{analyticsID}', 'auto');
        ga('send', 'pageview');

      </script>"

        analyticsCode
      end

    end

    def set_page_seo(content, type = 'title')
      if type == 'title'
        @seo_title = content
      elsif type == 'description'
        @seo_description = content
      end
    end

    # return the canonical meta tag if this is set to true in the admin panel

    def canonical_urls
      headtags = ''
      canonical = Setting.get('seo_canonical_urls')
      if canonical.to_s == 'Y'
        headtags = "<link rel=\"canonical\" href=\"#{site_url()}\" />\n"
      end
      headtags
    end

  end
end