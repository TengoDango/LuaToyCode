local e1x, e1y, e2x, e2y, width, height
local function transform(x, y, x0, y0)
    x, y = x - x0, y - y0
    return (x * e1x + y * e1y) / width, (x * e2x + y * e2y) / height
end

---Render spellcard background layer when is tile
---to use this render function, set self.img="img_void",
---then set self.tex to the sprite you want to render
---@param self table
function DG.TileRender(self)
    SetImageState(self.tex, self.blend, Color(self._cur_alpha * self.a, self.r, self.g, self.b))

    -- get axis
    e1x, e1y = cos(self.rot), sin(self.rot)
    e2x, e2y = -e1y, e1x

    -- get size
    width, height = GetImageSize(self.tex)
    width, height = width * self.hscale, height * self.vscale

    -- get map
    local w = lstg.world
    local p1x, p1y = transform(w.l, w.t, self.x, self.y)
    local p2x, p2y = transform(w.r, w.t, self.x, self.y)
    local p3x, p3y = transform(w.r, w.b, self.x, self.y)
    local p4x, p4y = transform(w.l, w.b, self.x, self.y)

    -- get bound
    local left = min(p1x, p2x, p3x, p4x)
    local right = max(p1x, p2x, p3x, p4x)
    local bottom = min(p1y, p2y, p3y, p4y)
    local top = max(p1y, p2y, p3y, p4y)

    -- tile render
    for i = math.floor(left + 0.5), math.ceil(right + 0.5) do
        for j = math.floor(bottom + 0.5), math.ceil(top + 0.5) do
            Render(self.tex,
                self.x + i * width * e1x + j * height * e2x,
                self.y + i * width * e1y + j * height * e2y,
                self.rot, self.hscale, self.vscale
            )
        end
    end
end
