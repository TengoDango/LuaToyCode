require "__init__"
----------------------------------------

print(DG.TryCatch {
    try = function()
        print(ran:Float(1,3))
    end,
    catch = function(errmsg)
        print(errmsg)
    end,
    finally = function ()
        print("this is a finally function")
    end,
    elsedo = function ()
        print("successful")
    end
})
