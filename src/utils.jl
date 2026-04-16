
global use_restartfiles=true

"""
    do_use_restartfiles()

Always use data from restartfiles if available.

Also see [`dont_use_restartfiles`](@ref)
"""
function do_use_restartfiles()
    global use_restartfiles=true
end
"""
    dont_use_restartfiles()

Always recompute values, do not use data from restartfiles.

Also see [`do_use_restartfiles`](@ref)
"""
function dont_use_restartfiles()
    global use_restartfiles=false
end
