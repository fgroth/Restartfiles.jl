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

"""
    get_all_keys(file::Union{HDF5.File,HDF5.Group})

Return Vector containing all entries within the Hdf5 restartfile.
"""
function get_all_keys(file::Union{HDF5.File,HDF5.Group})
    entries = keys(file)
    all_entries = Vector{Vector}(undef, length(entries))
    for i_entry in 1:length(entries)
        if isa(file[entries[i_entry]], HDF5.Dataset)
            # we reached the end
            all_entries[i_entry] = [entries[i_entry]]
        else
            # continue the search
            all_entries[i_entry] = [entries[i_entry], get_all_keys(file[entries[i_entry]])]
        end
    end
    return all_entries
end

"""
    print_all_keys(file::Union{HDF5.File,HDF5.Group})
    print_all_keys(entries::Vector; increment::Int64=0)

Print all keys in Hdf5 restartfile. Also see [`get_all_keys`](@ref).
"""
function print_all_keys(file::Union{HDF5.File,HDF5.Group})
    entries = get_all_keys(file)
    print_all_keys(entries)
end
function print_all_keys(entries::Vector; increment::Int64=0)
    for i_entry in 1:length(entries)
        println(repeat(" ",increment)*entries[i_entry][1])
        if length(entries[i_entry]) > 1
            print_all_keys(entries[i_entry][2], increment=increment+1)
        end
    end
end
