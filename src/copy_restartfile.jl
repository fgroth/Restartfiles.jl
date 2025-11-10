using HDF5

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
