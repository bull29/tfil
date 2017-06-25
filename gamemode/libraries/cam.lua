if SERVER then return end

local cam = cam

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