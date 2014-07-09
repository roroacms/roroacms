module MediaHelper

  #  -------- CURRENTLY UNUSED -------- #

  # establish a connection to S3
  AWS::S3::Base.establish_connection!(:access_key_id     => Setting.get('aws_access_key_id'), :secret_access_key => Setting.get('aws_secret_access_key'))
  BUCKET = Setting.get('aws_bucket_name')

  # require the dependencies
  include AWS::S3
  require 'digest/md5'


  # get all objects inside the BUCKET
  # Params:
  # +url+:: path that you want to get the objects from

  def media_setup_and_search_posts(url = nil)

    files =
      if url.nil?
        AWS::S3::Bucket.find("#{BUCKET}").objects
      else
        # if url is defined it will either get all objects inside a directory or get an inidividual
        # file depending on the type of string passed in through prefix
        AWS::S3::Bucket.objects(Setting.get('aws_bucket_name'), :prefix => url)
      end

    files

  end


  # create the object in S3 this  a directory
  # Params:
  # +params+:: the generic parameters
  # +url+:: path including the directory name

  def media_create(params, url = '')
    begin
      AWS::S3::S3Object.store(url + "#{params[:create_dir]}/", url + "#{params[:create_dir]}/", BUCKET, :access => :public_read, :content_type => 'binary/octet-stream')
      render :text => I18n.t("helpers.media_helper.media_create.success")
    rescue
      render :text => I18n.t("helpers.media_helper.media_create.fail")
    end
  end


  # create the object in S3 this is a file
  # Params:
  # +params+:: the generic parameters
  # +url+:: path including the folder name

  def media_advanced_create(params, url = '')

    if p[:reference].blank?
      dir = ''
      where = BUCKET
    else
      # create object inside the given directory
      dir = p[:reference]
      where = "#{BUCKET}/#{dir}"
    end

    begin
      @file = AWS::S3::S3Object.store(sanitize_filename(params[:file].original_filename), params[:file].read, where, :access => :public_read)
      render :text => "Success!"

    rescue ResponseError => error
      render :text => error.message
    end

  end


  # manually create the folder with the given url
  # Params:
  # +url+:: path including the folder name

  def manually_create_folder(url)
    AWS::S3::S3Object.store(url, url, BUCKET, :access => :public_read, :content_type => 'binary/octet-stream')
  end

  # manually create the folder with the given url
  # Params:
  # +p+:: uploaded file object
  # +user+:: username of the user
  # +initial_folder+:: is the initial folder name


  def upload_user_images(p, user, initial_folder = 'users')

    where = "#{BUCKET}/" + initial_folder.to_s + "/" + user.to_s + "/"

    begin

      @file = AWS::S3::S3Object.store(sanitize_filename(p.original_filename), p.read, where, :access => :public_read)
      S3Object.url_for("/" + initial_folder.to_s + "/" + user.to_s + "/" + p.original_filename, BUCKET, :authenticated => false)

    rescue ResponseError => error
      ''
    end

  end


  # return the size of the folder
  # Params:
  # +url+:: path to the directory or file that you want to find the size of
  # +human+:: human readable value or a value in bytes

  def get_folder_size(url, human = true)

    total_bytes = 0
    files = AWS::S3::Bucket.objects(Setting.get('aws_bucket_name'), :prefix => url)

    files.each do |f|
      total_bytes += f.size.to_i
    end

    human ? number_to_human_size(total_bytes) : total_bytes

  end


  # get media object by the key
  # Params:
  # +params+:: the generic parameters
  # +url+:: the path that you want to get a list of files and folders from

  def media_get_by_key(params, url = '')
    AWS::S3::Bucket.objects(Setting.get('aws_bucket_name'), :prefix => url + params[:key])
  end


  # get a list of folders in the amazon S3 account
  # Params:
  # +params+:: the generic parameters
  # +url+:: the path that you want to get a list of files and folders from

  def media_get_folder_list(params, url = nil)

    files = setup_and_search_posts(url)
    array = Array.new

    files.each_with_index do |item, index|
      next if item.content_type != 'binary/octet-stream'
      array.push item
    end

    array

  end


  # delete all with the prefix of the given prefix
  # Params:
  # +prefix+:: the path that you want to delete. THis will delete everything in the prefix

  def delete_all(prefix)

    obj = AWS::S3::Bucket.objects(BUCKET, :prefix => prefix)
    obj.each do |f|
      AWS::S3::S3Object.find(f.key, BUCKET).delete
    end

  end

  private

  # delete all with the prefix of the given prefix
  # Params:
  # +prefix+:: string to the file name that you want to store the file

  def sanitize_filename(file_name)
    just_filename = File.basename(file_name)
    just_filename.sub(/[^\w\.\-]/,'_')
  end

end
