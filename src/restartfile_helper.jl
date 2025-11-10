using HDF5

"""
    restartfile_name(cluster::String, method::String="")

Return name of the restartfile for given `cluster` and `method` name.
"""
function restartfile_name(cluster::String, method::String="")
    if method != ""
        method = "_"*method
    end
    return joinpath("restartfiles",cluster*method*".h5")
end
"""
    restartfile_name_from_snapshot(snap::String)

Return name of retartfile for given snapshot name.
Assume default format of OutputDir: "out_cluster_method".

See also `restartfile_name`.
"""
function restartfile_name_from_snapshot(snap::String)
    snap_components = splitpath(snap)
    # name of the OutputDir
    if startswith(snap_components[end-1], "snapdir_")
        outdir_name = snap_components[end-2]
    else # single sub-snapshot
        outdir_name = snap_components[end-1]        
    end
    # we assume our regular format: out_cluster_method
    outdir_components = split(outdir_name,"_")
    cluster = outdir_components[2]
    method = outdir_components[3]
    for i_method in 4:length(outdir_components)
        method *= "_"*outdir_components[i_method]
    end
    return restartfile_name(String(cluster), String(method))
end

"""
    save_property_to_restartfile(cluster::String, method::String="";
                                 property::Union{String,Vector{String}}, value)

Save the `value` under the name `property` in the restartfile.
"""
function save_property_to_restartfile(cluster::String, method::String="";
                                      property::Union{String,Vector{String}}, value)
    save_property_to_restartfile_name(restartfile_name(cluster, method),
                                      property=property, value=value)
end
"""
    save_property_to_restartfile_name(restartfile::String;
                                      property::Union{String,Vector{String}}, value)

Save the `value` under the name `property` in the restartfile.
"""
function save_property_to_restartfile_name(restartfile::String;
                                           property::Union{String,Vector{String}}, value)
    if !isfile(restartfile)
        mode = "w"
    else
        mode = "r+"
    end
    h5open(restartfile,mode) do file
        save_property_to_restartfile(file, property=property, value=value)
    end
end
"""
    save_property_to_restartfile(file::Union{HDF5.File,HDF5.Group};
                                 property::Union{String,Vector{String}}, value)

Save the `value` under the name `property` in the restartfile.
"""
function save_property_to_restartfile(file::Union{HDF5.File,HDF5.Group};
                                      property::Union{String,Vector{String}}, value)
    group = create_groups_as_necessary(file, property)
    if typeof(property) == String
        if is_in_restartfile(group, property)
            delete_property_from_restartfile(group, property=property)
        end
        group[property] = value
    else
        if is_in_restartfile(group, property[end])
            delete_property_from_restartfile(group, property=property[end])
        end
        group[property[end]] = value
        save_property_to_restartfile(group, property=property[end], value=value)
    end
end

"""
    delete_property_from_restartfile(cluster::String, method::String="";
                                     property::Union{String,Vector{String}})

Mark property as deleted in hdf5 restartfile.

This function assumes the property has been saved to the restartfile and throws an error otherwise.
"""
function delete_property_from_restartfile(cluster::String, method::String="";
                                          property::Union{String,Vector{String}})
    delete_property_from_restartfile_name(restartfile_name(cluster, method), property=property)
end
"""
    delete_property_from_restartfile_name(restartfile::String;
                                          property::Union{String,Vector{String}})

Mark property as deleted in hdf5 restartfile.

This function assumes the property has been saved to the restartfile and throws an error otherwise.
"""
function delete_property_from_restartfile_name(restartfile::String;
                                               property::Union{String,Vector{String}})
    h5open(restartfile,"r+") do file
        group = create_groups_as_necessary(file, property)
        if typeof(property) == String
            delete_property_from_restartfile(group, property=property)
        else
            delete_property_from_restartfile(group, property=property[end])
        end
    end    
end
"""
    delete_property_from_restartfile(file::Union{HDF5.File,HDF5.Group};
                                     property::Union{String,Vector{String}})

Mark property as deleted in hdf5 restartfile.

This function assumes the property has been saved to the restartfile and throws an error otherwise.
"""
function delete_property_from_restartfile(file::Union{HDF5.File,HDF5.Group};
                                          property::Union{String,Vector{String}})
    delete_object(file,property)
end
    
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
    cleanup_restartfile(cluster::String, method::String="")

Remove all deleted entries and compactify the file.
"""
function cleanup_restartfile(cluster::String, method::String="")
    cleanup_restartfile_name(restartfile_name(cluster, method))
end
"""
    cleanup_restartfile_name(restartfile::String)

Remove all deleted entries and compactify the file.
"""
function cleanup_restartfile_name(restartfile::String)
    # Open original file in read-only mode
    src = h5open(restartfile, "r")
    tmp_file = tempname(cleanup=false)
    # Create a clean new file
    dest = h5open(tmp_file, "w")
    try
        recursive_copy(src, dest)
    finally
        close(src)
        close(dest)
    end
    mv(tmp_file, restartfile, force=true)
end
"""
    recursive_copy(src::Union{HDF5.File,HDF5.Group}, dest::Union{HDF5.File,HDF5.Group})

Recursively copies all datasets and attributes from src_group to dest_group.
"""
function recursive_copy(src::Union{HDF5.File,HDF5.Group}, dest::Union{HDF5.File,HDF5.Group})
    # Copy global attributes of group / file
    for attr_name in keys(attributes(src))
        attr_value = read_attribute(src, attr_name)
        write_attribute(dest, attr_name, attr_value)
    end
    # now copy over all data
    for name in keys(src)
        obj = src[name]
        if isa(obj, HDF5.Group)
            new_group = create_group(dest, name)
            recursive_copy(obj, new_group)
        elseif isa(obj, HDF5.Dataset)
            data = read(obj)
            dest[name] = data
            # Copy attributes of the dataset
            for attr_name in keys(attributes(obj))
                attr_value = read_attribute(obj, attr_name)
                write_attribute(dest[name], attr_name, attr_value)
            end
        end
    end
end

"""
    create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::Vector{String})

Create all necessary group hierarchy if not present yet.
"""
function create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::Vector{String})    
    group = file
    for group_hierarchy_level in 1:length(group_location)-1
        if !haskey(group, group_location[group_hierarchy_level])
            group = create_group(group, group_location[group_hierarchy_level])
        else
            group = group[group_location[group_hierarchy_level]]
        end
    end
    return group
end
"""
    create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::String)

Just return `file`, as no action is necessary.
"""
function create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::String)    
    return file
end

"""
    add_metadata_to_restartfile(cluster::String, method::String="";
                                property::Union{String,Vector{String}}, metadata::Dict{String,<:Any})

Save metadata as attribute to the `property` in the restartfile.
This assumes that `property` is already within the restartfile.
"""
function add_metadata_to_restartfile(cluster::String, method::String="";
                                     property::Union{String,Vector{String}}, metadata::Dict{String,<:Any})
        add_metadata_to_restartfile_name(restartfile_name(cluster, method),
                                         property=property, metadata=metadata)
end
"""
    add_metadata_to_restartfile_name(restartfile::String;
                                     property::Union{String,Vector{String}}, metadata::Dict{String,<:Any})

Save metadata as attribute to the `property` in the restartfile.
This assumes that `property` is already within the restartfile.
"""
function add_metadata_to_restartfile_name(restartfile::String;
                                          property::Union{String,Vector{String}}, metadata::Dict{String,<:Any})
    if !isfile(restartfile)
        mode = "w"
    else
        mode = "r+"
    end
    h5open(restartfile,mode) do file
        add_metadata_to_restartfile(file, property=property, metadata=metadata)
    end
end
"""
    add_metadata_to_restartfile(file::Union{HDF5.File,HDF5.Group};
                                property::Union{String,Vector{String}}, metadata::Dict{String,<:Any})

Save metadata as attribute to the `property` in the restartfile.
This assumes that `property` is already within the restartfile.
"""
function add_metadata_to_restartfile(file::Union{HDF5.File,HDF5.Group};
                                     property::Union{String,Vector{String}}, metadata::Dict{String,<:Any})
    group = create_groups_as_necessary(file, property)
    # go even one step further, we need teh actual property location
    if typeof(property) == String
        group = group[property]
    elseif length(property) > 0 # if the length is zero, we are adding global information on the file level.
        group = group[property[end]]
    end
    # now we can write all information to the file
    for (key, value) in metadata
        attrs(group)[key] = value
    end
end
