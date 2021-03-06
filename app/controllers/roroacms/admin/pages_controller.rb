module Roroacms

  class Admin::PagesController < AdminController

    # displays all the "posts" with the post_type of "page". This is also set up
    # to take search parameters so you can search for an individual page itself.

    add_breadcrumb I18n.t("generic.pages"), :admin_pages_path, :title => I18n.t("controllers.admin.pages.breadcrumb_title")

    before_filter :set_post_type

    def index
      set_title(I18n.t("generic.pages"))
      @pages = Post.setup_and_search_posts params, 'page'
    end


    # creates a new post object

    def new
      # add breadcrumb and set title
      add_breadcrumb I18n.t("controllers.admin.pages.new.breadcrumb")
      set_title(I18n.t("controllers.admin.pages.new.title"))

      @record = Post.new
      @action = 'create'
    end


    # create the post object

    def create
      @record = Post.new(page_params)
      @record.additional_data(params[:additional_data])

      respond_to do |format|

        if @record.save
          format.html { redirect_to admin_pages_path, notice: I18n.t("controllers.admin.pages.create.flash.success") }
        else
          format.html {
            # add breadcrumb and set title
            add_breadcrumb I18n.t("controllers.admin.pages.new.breadcrumb")
            @action = 'create'
            flash[:error] = I18n.t('generic.validation.no_passed')
            render action: "new"
          }
        end

      end

    end


    # gets and displays the post object with the necessary dependencies

    def edit
      @edit = true
      @record = Post.find(params[:id])

      # add breadcrumb and set title
      add_breadcrumb I18n.t("controllers.admin.pages.edit.breadcrumb")
      set_title(I18n.t("controllers.admin.pages.edit.title", post_title: @record.post_title))
      @action = 'update'
    end


    # updates the post object with the updates params

    def update
      @record = Post.find(params[:id])
      @record.additional_data(params[:additional_data])
      @record.deal_with_cover(params[:has_cover_image])

      respond_to do |format|

        if @record.update_attributes(page_params)

          format.html { redirect_to edit_admin_page_path(@record.id), notice: I18n.t("controllers.admin.pages.update.flash.success") }

        else
          format.html {
            # add breadcrumb and set title
            add_breadcrumb I18n.t("controllers.admin.pages.edit.breadcrumb")
            @record.post_title.blank? ? I18n.t("controllers.admin.pages.edit.title_blank") : I18n.t("controllers.admin.pages.edit.title", post_title: @record.post_title)
            @action = 'update'
            flash[:error] = I18n.t('generic.validation.no_passed')
            render action: "edit"
          }
        end

      end
    end


    # deletes the post

    def destroy
      Post.disable_post(params[:id])
      respond_to do |format|
        format.html { redirect_to admin_pages_path, notice: I18n.t("controllers.admin.pages.destroy.flash.success") }
      end
    end


    # Takes all of the checked options and updates them with the given option selected.
    # The options for the bulk update in pages area are:-
    # - Publish
    # - Draft
    # - Move to trash

    def bulk_update
      # returns a message to disply to the user
      notice = Post.bulk_update(params, 'pages')
      respond_to do |format|
        format.html { redirect_to admin_pages_path, notice: notice }
      end
    end

    private


    # Strong parameters

    def page_params
      params.require(:post).permit(:admin_id, :post_content, :post_date, :post_name, :parent_id, :post_slug, :post_visible, :sort_order, :post_status, :post_title, :cover_image, :post_template, :post_type, :disabled, :post_seo_title, :post_seo_description, :post_seo_keywords, :post_seo_is_disabled, :post_seo_no_follow, :post_seo_no_index)
    end

    # used for the form to set the type of post as the form is used for both articles and pages

    def set_post_type
      @post_type ||= 'page'
    end
    
  end

end
