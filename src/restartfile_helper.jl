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
