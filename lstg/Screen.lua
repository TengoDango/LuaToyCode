---@class Lstg.World
lstg.world = {
    l = -192,
    r = 192,
    b = -224,
    t = 224,
    boundl = -224,
    boundr = 224,
    boundb = -256,
    boundt = 256,
    scrl = 6,
    scrr = 390,
    scrb = 16,
    scrt = 464,
    pl = -192,
    pr = 192,
    pb = -224,
    pt = 224,
}

---@class Lstg.View3D
lstg.view3d = {
    eye = { 0, 0, -1 },
    at = { 0, 0, 0 },
    up = { 0, 1, 0 },
    fovy = math.pi / 2,
    z = { 0, 2 },
    fog = { 0, 0, Color(0x00000000) },
}

---@class Lstg.Screen
screen = {
    width = 640, height = 480, dx = 0, dy = 0, scale = 3,
}
