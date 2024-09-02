function onCreate()
	makeLuaSprite('bg',null,0,0)
	makeGraphic('bg',1280,720,"EE00EE")
	setObjectCamera('bg','camHUD')
	setProperty('bg.alpha',1)
	setProperty('bg.scale.x',2)
	setProperty('bg.scale.y',2)
	addLuaSprite('bg',true)
	setBlendMode('bg','subtract')

	close(false);
end