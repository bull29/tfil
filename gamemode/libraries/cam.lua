if SERVER then return end

local cam = cam
local render = render
local windows = system.IsWindows()

function cam.Wrap2D( func, ... )
	cam.Start2D( ... )
		func()
	cam.End2D()
end

function cam.Wrap3D( func, ... )
	cam.Start3D( ... )
		func()
	cam.End3D()
end

function cam.Wrap3D2D( func, ... )
	cam.Start3D2D( ... )
		func()
	cam.End3D2D()
end

function render.Clip( tab, func )
	if not windows then
		return func()
	end
	render.EnableClipping( true )
	for i = 1, #tab do
		render.PushCustomClipPlane( tab[i][1], tab[i][2])
	end
	func()
	for i = 1, #tab do
		render.PopCustomClipPlane()
	end
	render.EnableClipping(false)
end