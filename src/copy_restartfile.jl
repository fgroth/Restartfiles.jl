using HDF5

"""
    copy_restartfile_properties(cluster::String, method::String="";
                                kwargs...)

Copy all properties to new restartfile. See `copy_restartfile_properties_name`.
"""
function copy_restartfile_properties(cluster::String, method::String="";
                                     kwargs...)
    copy_restartfile_properties_name(restartfile_name(cluster, method);
                                     kwargs...)
end
"""
    copy_restartfile_properties_name(restartfile::String;
                                     new_restartfile::String="", properties::Vector)

Copy all properties to `new_restartfile`. If this is an empty String, use `restartfile*"_new.h5"` as new name.
"""
function copy_restartfile_properties_name(restartfile::String;
                                          new_restartfile::String="", properties::Vector)
    src = h5open(restartfile, "r")
    if new_restartfile == ""
        new_restartfile = restartfile[1:end-3]*"_new.h5"
    end
    dest = h5open(new_restartfile, "w")
    for property in properties
        src_obj = create_groups_as_necessary(src,property)
        src_obj = src_obj[property[end]]
        dest_obj = create_groups_as_necessary(dest, property, copy_from=src)
        # make sure the last layer is prepared as well
        if isa(src_obj, HDF5.Dataset)
            # use some trick to make sure we always have the correct name, both for String and Vector{String} type property.
            dest_obj = create_dataset(dest_obj, vcat(property,"")[end-1], datatype(src_obj), dataspace(src_obj))
        else
            dest_obj = create_groups_as_necessary(dest_obj, vcat(property[end],""))
        end

        recursive_copy(src_obj, dest_obj)
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
    copied_successfull= try
        recursive_copy(src, dest)
        true
    catch
        false
    finally
        close(src)
        close(dest)
    end
    if copied_successfull
        mv(tmp_file, restartfile, force=true)
    end
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
            println(dest)
            dest_obj = create_dataset(dest, name, datatype(obj), dataspace(obj))
            recursive_copy(obj, dest_obj)
        end
    end
end
"""
    recursive_copy(src::HDF5.Dataset, dest::HDF5.Dataset)

Copy over the dataset from `src` to `dest`
"""
function recursive_copy(src::HDF5.Dataset, dest::HDF5.Dataset)
    data = read(src)
    write(dest, data)
    # Copy attributes of the dataset
    for attr_name in keys(attributes(src))
        attr_value = read_attribute(src, attr_name)
        write_attribute(dest, attr_name, attr_value)
    end
end
