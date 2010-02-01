# encoding: utf-8

require 'carrierwave/orm/activerecord'

class Mp3Uploader < CarrierWave::Uploader::Base

  if CONFIG['s3']
    storage :s3
    def store_dir; ""; end
  else
    storage :file
    def store_dir; "system"; end
  end

  def filename
    @random_filename ||= ActiveSupport::SecureRandom.hex(20)
    "#{@random_filename}#{File.extname(original_filename).downcase}" if original_filename
  end

  def s3_headers
    {'Cache-Control' => 'max-age=315576000', 'Expires' => 99.years.from_now.httpdate} # TODO specify globally instead
  end
end