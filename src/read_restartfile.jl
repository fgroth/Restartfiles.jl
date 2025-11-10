using HDF5

"""
    read_property_from_restartfile(cluster::String, method::String="";
                                   property::Union{String,Vector{String}})

Return value of property for given cluster.

This function assumes the property has been saved to the restartfile and throws an error otherwise.
"""
function read_property_from_restartfile(cluster::String, method::String="";
                                        property::Union{String,Vector{String}})
    read_property_from_restartfile_name(restartfile_name(cluster, method), property=property)
end
"""
    read_property_from_restartfile_name(restartfile::String;
                                        property::Union{String,Vector{String}})

Return value of property for given restartfile name.

This function assumes the property has been saved to the restartfile and throws an error otherwise.
"""
function read_property_from_restartfile_name(restartfile::String;
                                             property::Union{String,Vector{String}})
    h5open(restartfile,"r") do file
        return read_property_from_restartfile(file, property=property)
    end
end
"""
    read_property_from_restartfile(file::Union{HDF5.File,HDF5.Group};
                                   property::Union{String,Vector{String}})

Return value of property for given cluster.

This function assumes the property has been saved to the restartfile and throws an error otherwise.
"""
function read_property_from_restartfile(file::Union{HDF5.File,HDF5.Group};
                                        property::Union{String,Vector{String}})
    group = create_groups_as_necessary(file, property)
    if typeof(property) == String
        return read(group[property])
    else
        return read(group[property[end]])
    end
end
