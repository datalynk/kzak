class Post < ActiveRecord::Base
  require 'open-uri'
  
  attr_accessible :attachment, :attachment_url, :attachment_remote_url
  attr_accessor :attachment_url  
  
  if CONFIG['s3']
    has_attached_file :attachment, 
                      :storage => :s3, 
                      :path => ":filename", 
                      :bucket => CONFIG['s3_bucket_name'],
                      :s3_credentials => { :access_key_id => CONFIG['s3_access_id'], :secret_access_key => CONFIG['s3_secret_key'] },
                      :s3_headers => { 'Cache-Control' => 'max-age=315576000', 'Expires' => 10.years.from_now.httpdate }
  else
    has_attached_file :attachment, 
                      :storage => :filesystem, 
                      :url => "/uploads/:filename"
  end
  
  belongs_to :user, :counter_cache => :posts_count
  
  before_validation :download_remote_file, :if => :attachment_url_provided?
    
  validates_presence_of :user_id, :attachment_file_name
  validates_presence_of :attachment_remote_url, :if => :attachment_url_provided?, :message => 'is invalid or inaccessible'
  validates_uniqueness_of :attachment_file_name
  validates_attachment_content_type :attachment, :content_type => /mp3/
  
  after_create :create_feed_items
  
  default_scope :order => 'created_at DESC'
  
  def create_feed_items
    FeedItem.populate(self)
  end
  
  def to_s
    attachment_file_name
  end
  
  protected
  
  def attachment_url_provided?
    !self.attachment_url.blank?
  end
  
  def download_remote_file
    self.attachment = do_download_remote_file
    self.attachment_remote_url = attachment_url
  end
  
  def do_download_remote_file
    io = open(URI.parse(attachment_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
end
