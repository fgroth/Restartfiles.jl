module Restartfiles

include(joinpath("restartfile_helper.jl"))
export restartfile_name, restartfile_name_from_snapshot,
    save_property_to_restartfile, save_property_to_restartfile_name,
    delete_property_from_restartfile, delete_property_from_restartfile_name,
    is_in_restartfile, is_in_restartfile_name,
    read_property_from_restartfile, read_property_from_restartfile_name,
    cleanup_restartfile, cleanup_restartfile_name

end # module
