module Restartfiles

include(joinpath("restartfile_helper.jl"))
export restartfile_name, restartfile_name_from_snapshot

include(joinpath("check_restartfile.jl"))
export is_in_restartfile, is_in_restartfile_name

include(joinpath("read_restartfile.jl"))
export read_property_from_restartfile, read_property_from_restartfile_name

include(joinpath("write_restartfile.jl"))
export save_property_to_restartfile, save_property_to_restartfile_name,
    delete_property_from_restartfile, delete_property_from_restartfile_name,
    add_metadata_to_restartfile, add_metadata_to_restartfile_name

include(joinpath("copy_restartfile.jl"))
export cleanup_restartfile, cleanup_restartfile_name

end # module
