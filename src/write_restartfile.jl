using HDF5

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
    create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::Vector{String};
                               copy_from::Union{HDF5.File,HDF5.Group}=nothing)

Create all necessary group hierarchy if not present yet.
"""
function create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::Vector{String};
                                    copy_from::Union{Nothing,HDF5.File,HDF5.Group}=nothing)
    group = file
    if !isa(copy_from,Nothing)
        copy_group = copy_from
        known_attr_names = keys(attributes(group))
        for attr_name in keys(attributes(copy_group))
            if !(attr_name in known_attr_names)
                attr_value = read_attribute(copy_group, attr_name)
                write_attribute(group, attr_name, attr_value)
            end
        end
    end
    for group_hierarchy_level in 1:length(group_location)-1
        if !haskey(group, group_location[group_hierarchy_level])
            group = create_group(group, group_location[group_hierarchy_level])
            if !isa(copy_from,Nothing)
                copy_group = copy_group[group_location[group_hierarchy_level]]
                for attr_name in keys(attributes(copy_group))
                    attr_value = read_attribute(copy_group, attr_name)
                    write_attribute(group, attr_name, attr_value)
                end
            end
        else
            group = group[group_location[group_hierarchy_level]]
        end
    end
    return group
end
"""
    create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::String;
                               copy_from::Union{HDF5.File,HDF5.Group}=nothing)

Just return `file`, as no action is necessary.
"""
function create_groups_as_necessary(file::Union{HDF5.File,HDF5.Group}, group_location::String;
                                    copy_from::Union{HDF5.File,HDF5.Group}=nothing)
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
