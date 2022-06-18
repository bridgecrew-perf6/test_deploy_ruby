PDFKit.configure do |config|
  #config.wkhtmltopdf = 'E:/wkhtmltopdf/wkhtmltopdf.exe'
  config.default_options = {
    :page_size => 'A4',
  #  :print_media_type => true
  }
 #config.root_url = "http://lvh.me:3000" # Use only if your external hostname is unavailable on the server.
end
ActionController::Base.asset_host = Proc.new { |source, request|
  if request.format.pdf?
    "#{request.protocol}#{request.host_with_port}"
  else
    nil
  end
}