# Restartfiles

This package provides wrapper functions for [HDF5](https://juliaio.github.io/HDF5.jl), to easily read and write hierarchical data for hdf5 restartfiles.

The default restartfile names are `restartfiles/cluster(*"_"*method).h5`, see `restartfile_name`, `restartfile_name_from_snapshot`. Alternatively, all functions exist with a `_name` suffix, that allow for self-defined naming conventions.

## Reading

Use `read_property_from_restartfile(_name)`.

To check the content of the restartfile, use `print_all_keys`. Also see `get_all_keys`.

## Writing

Use `save_property_to_restartfile(_name)`, `delete_property_from_restartfile(_name)`, `add_metadata_to_restartfile(_name)`.

## Cleanup

Hdf5 files don't delete old content, but only hide the data. If you want to properly cleanup the file (e.g. to publish the data, or just to decrease the size), use `cleanup_restartfile(_name)`.
Only specific properties can be copied using `copy_restartfile_properties(_name)`.
