# Restartfiles

This package provides wrapper functions for [HDF5](https://juliaio.github.io/HDF5.jl), to easily check, read, and write hierarchical data for hdf5 restartfiles.

The default restartfile names are `restartfiles/cluster(*"_"*method).h5`, see `restartfile_name`, `restartfile_name_from_snapshot`. Alternatively, all functions exist with a `_name` suffix, that allow for self-defined naming conventions.

## Using Restartfiles
The module exports the `use_restartfiles` variable, that can be used to decide if restartfiles should be used in general when using this package. By default, it is `true`. The value can be modified using the `do(nt)_use_restartfiles` functions.

The variable should be checked for either explicitely whenever a decision between using restartfiles and recomputing values is present. The `restartfile_exists_with_properties(_name)` function does that check internally, so if this is used, no additional check is necessary.

## Checking
You can check for a specific property to be present in a restartfile using `is_in_restartfile(_name)`. To check for several properties, as well as existance of the file, use `restartfile_exists_with_properties(_name)`.

## Reading

Use `read_property_from_restartfile(_name)`.

To check the content of the restartfile, use `print_all_keys`. Also see `get_all_keys`.

## Writing

Use `save_property_to_restartfile(_name)`, `delete_property_from_restartfile(_name)`, `add_metadata_to_restartfile(_name)`.

To write several properties to the same restartfile, also the functions `save_all_properties_to_restartfile(_name)` can be used.

## Cleanup

Hdf5 files don't delete old content, but only hide the data. If you want to properly cleanup the file (e.g. to publish the data, or just to decrease the size), use `cleanup_restartfile(_name)`.
Only specific properties can be copied using `copy_restartfile_properties(_name)`.
