# Subclass from main ApplicationController, which will subclass from DmCore
#------------------------------------------------------------------------------
class DmCore::ProtectedAssetsController < ::ApplicationController
  # serves an asset from the account's protected_assets directory
  # Expects the protected files to be in #{Rails.root}/protected_assets/uploads/#{theme_name}
  # typically symlinked from whereever they are stored (such as in the shared directory)
  # Note: we check the expanded path against the base path to make sure there
  # any '..' in the path didn't kick us out of where we're supposed to be.
  #------------------------------------------------------------------------------
  def protected_asset
    # expand and make sure we're in the protected_asset directory.  We purposefully add the
    # media path - this ensures that we're only accessing files from this domain.
    request_file = File.expand_path(File.join(account_protected_assets_media_folder, params[:asset]))

    if File.exist?(request_file) && request_file.start_with?(account_protected_assets_media_folder) && user_signed_in?
      # for Apache xsendfile, we *might* need to use send_file(File.realpath(request_file)...
      send_file(request_file, disposition: 'inline',
                              type: Mime::Type.lookup_by_extension(File.extname(request_file)[1..-1]))
    else
      head :not_found
    end
  end
end
