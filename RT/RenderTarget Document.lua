---@meta RenderTarget

----------------------------------------

---@class DGlib.RenderTarget
local rtobject = {}

---@alias DGlib.ViewMode
---| "" # Default, depend on current lstg.viewmode and whether setting xyz or uv
---| "world" # View at world coordinate
---| "ui" # View at ui coordinate
---| "uv" # View at texture coordinate

----------------------------------------

---Create an instance of DGlib.RenderTarget
---@param name string # Name of render target to bind
---@return DGlib.RenderTarget
function DG.RenderTarget(name) end

---Copy an instance of DGlib.RenderTarget
---@return DGlib.RenderTarget
function rtobject:copy() end

----------------------------------------

---Push render target
---@return DGlib.RenderTarget self
function rtobject:push() end

---Pop render target
---@return DGlib.RenderTarget self
function rtobject:pop() end

---Render the render target on screen
---@return DGlib.RenderTarget self
function rtobject:render() end

----------------------------------------

---Set render target
---@param name string # Name of render target to bind
---@return DGlib.RenderTarget self
function rtobject:texture(name) end

---Set blend mode
---@param blend lstg.BlendMode?
---@return DGlib.RenderTarget self
function rtobject:blend(blend) end

---Set vertex color to white
---@return DGlib.RenderTarget self
function rtobject:color() end

---Set vertex color
---@param color lstg.Color
---@return DGlib.RenderTarget self
function rtobject:color(color) end

---Set vertex color
---@param c1 lstg.Color # left top
---@param c2 lstg.Color # right top
---@param c3 lstg.Color # right bottom
---@param c4 lstg.Color # left bottom
---@return DGlib.RenderTarget self
function rtobject:color(c1, c2, c3, c4) end

----------------------------------------

---Set vertex (x,y), param similar to lstg.Render()
---@param viewmode DGlib.ViewMode
---@param x number # center x
---@param y number # center y
---@param rot number? # default = 0
---@param hscale number? # default = 0
---@param vscale number? # default = 0
---@return DGlib.RenderTarget self
function rtobject:xy(viewmode, x, y, rot, hscale, vscale) end

---Set vertex (x,y), param similar to lstg.RenderRect()
---@param viewmode DGlib.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number? # default = 0
---@return DGlib.RenderTarget self
function rtobject:xyrect(viewmode, left, right, bottom, top, rot) end

---Set vertex (x,y), param similar to lstg.Render4V()
---@param viewmode DGlib.ViewMode
---@param x1 number # left top
---@param y1 number
---@param x2 number # right top
---@param y2 number
---@param x3 number # left bottom
---@param y3 number
---@param x4 number # right bottom
---@param y4 number
---@return DGlib.RenderTarget self
function rtobject:xy4v(viewmode, x1, y1, x2, y2, x3, y3, x4, y4) end

---Set vertex (x,y,z), param similar to lstg.Render4V()
---@param x1 number # left top
---@param y1 number
---@param z1 number
---@param x2 number # right top
---@param y2 number
---@param z2 number
---@param x3 number # right bottom
---@param y3 number
---@param z3 number
---@param x4 number # left bottom
---@param y4 number
---@param z4 number
---@return DGlib.RenderTarget self
function rtobject:xyz(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4) end

---Discard vertex (x,y), use default (x,y) strategy
---@return DGlib.RenderTarget self
function rtobject:xy() end

----------------------------------------

---Set vertex (u,v), param similar to lstg.Render()
---@param viewmode DGlib.ViewMode
---@param u number # center u
---@param v number # ceter v
---@param rot number? # default = 0
---@param a number # half width
---@param b number? # half height, default = a
---@return DGlib.RenderTarget self
function rtobject:uv(viewmode, u, v, rot, a, b) end

---Set vertex (u,v), param similar to lstg.RenderRect()
---@param viewmode DGlib.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number? # default = 0
---@return DGlib.RenderTarget self
function rtobject:uvrect(viewmode, left, right, bottom, top, rot) end

---Set vertex (u,v), param similar to lstg.Render4V()
---@param viewmode DGlib.ViewMode
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
---@param u3 number
---@param v3 number
---@param u4 number
---@param v4 number
---@return DGlib.RenderTarget self
function rtobject:uv4v(viewmode, u1, v1, u2, v2, u3, v3, u4, v4) end

---Discard vertex (u,v), use default (u,v) strategy
---@return DGlib.RenderTarget self
function rtobject:uv() end

----------------------------------------

---Set center (u,v), similar to lstg.SetImageCenter()
---barely useful
---@param viewmode DGlib.ViewMode
---@param u number
---@param v number
---@return DGlib.RenderTarget self
function rtobject:center(viewmode, u, v) end

---Discard center (u,v), use default center strategy
---@return DGlib.RenderTarget self
function rtobject:center() end
