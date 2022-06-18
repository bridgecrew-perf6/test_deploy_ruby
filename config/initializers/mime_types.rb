# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register "application/xls", :xls
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
Mime::Type.register "application/vnd.oasis.opendocument.spreadsheet, application/x-vnd.oasis.opendocument.spreadsheet", :ods
Mime::Type.register_alias "application/pdf", :pdf unless Mime::Type.lookup_by_extension(:pdf)