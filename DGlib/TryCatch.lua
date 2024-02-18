---@class DGlib.TryCatch.Data
local trycatch = {
    ---Try to execute, necessary
    ---@param ... any
    try = function(...) end,
    ---Execute when an error occurs, unnecessary
    ---@param errmsg string
    catch = function(errmsg) end,
    ---Execute when no error occur, unnecessary
    elsedo = function() end,
    ---Execute whatever case, unnecessary
    finally = function() end,
}

local function handleError(errmsg)
    return table.concat({
        errmsg or "unknown exception",
        "<=== inner traceback ===>",
        debug.traceback(),
        "<=======================>",
    }, "\n")
end

---Execute a try-catch-else-finally block
---@param data DGlib.TryCatch.Data
---@param ... any # parameters for try-function
function DG.TryCatch(data, ...)
    local try, catch = data.try, data.catch
    local elsedo, finally = data.elsedo, data.finally

    local result = { xpcall(try, handleError, ...) }
    if result[1] then
        if elsedo then elsedo() end
        if finally then finally() end
        return true
    else
        if catch then catch(result[2]) end
        if finally then finally() end
        return false
    end
end
