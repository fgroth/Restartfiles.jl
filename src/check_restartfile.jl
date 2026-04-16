using HDF5

"""
    is_in_restartfile(cluster::String, method::String="";
                      property::Union{String,Vector{String}})

Returns if the property has been saved to the restartfile.

This function assumes that the restartfile exists and throws and error otherwise.
"""
function is_in_restartfile(cluster::String, method::String="";
                           property::Union{String,Vector{String}})
    is_in_restartfile_name(restartfile_name(cluster, method), property=property)
end
"""
    is_in_restartfile(cluster::String, method::String="";
                      property::Union{String,Vector{String}})

Returns if the property has been saved to the restartfile.

This function assumes that the restartfile exists and throws and error otherwise.
"""
function is_in_restartfile_name(restartfile::String;
                                property::Union{String,Vector{String}})
    h5open(restartfile,"r") do file
        return is_in_restartfile(file, property)
    end
end
"""
    is_in_restartfile(file::Union{HDF5.File,HDF5.Group},property::String)

Returns if the property has been saved to the restartfile.
"""
function is_in_restartfile(file::Union{HDF5.File,HDF5.Group},property::String)
    return haskey(file, property)
end
"""
    is_in_restartfile(file::Union{HDF5.File,HDF5.Group},property::Vector{String})

Returns if the property has been saved to the restartfile.
"""
function is_in_restartfile(file::Union{HDF5.File,HDF5.Group},property::Vector{String})
    key = property[1]
    for i_level in 2:length(property)
        key = key*"/"*property[i_level]
    end
    return haskey(file, key)
end

"""
    restartfile_exists_with_properties(restartfile::String; properties::Vector{<:Union{String,Vector{String}}})

Return true if:
- restartfiles should be used in general (`use_restartfiles`)
- and restartfile exists
- and all properties are present
"""
function restartfile_exists_with_properties(restartfile::String; properties::Vector{<:Union{String,Vector{String}}})
    if use_restartfiles &&
        isfile(restartfile)
        for property in properties
            if !is_in_restartfile_name(restartfile, property=property)
                # some property is missing
                return false
            end
        end
        # all properties are present
        return true
    end
    # either we should not use restartfiles in general or the restartfile does not exist
    return false
end

