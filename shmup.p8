pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- main tab
function _init()
	cls(0)	
	cartdata("space_blitz")
	startscreen()
	t=0
	blinkt=1
	readyt=1
	lockout=0
	debug="phasetest"
	animtable={
		anykey=animcurve({6,2,14,2,6},
																			{5,6,7,6,5}),
		ready=animcurve({20,20,20},
																		{"3","2","1"})
		}
	shake=0
	highscore=dget(0)
	version="v1"
	
end

function _update()
	t+=1
	blinkt+=1
	
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover()
	elseif mode=="ready" then
		readyt+=1
		update_ready()
	elseif mode=="wavetext" then
		update_wavetext()
	elseif mode=="win" then
		update_win()
	end
end

function _draw()
	doshake()

	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="gameover" then
		draw_gameover()
	elseif mode=="ready" then
		draw_ready()
	elseif mode=="wavetext" then
		draw_wavetext()
	elseif mode=="win" then
		draw_win()
	end
	camera()
end

function startscreen()
	starsetup()
	mode="start"
	music(11)
end

function startgame()
	t=0
	readyt=1
	wave=0
	
	nextwave()
	
	ship=makespr()
	ship.x=64
	ship.y=90
	ship.spdx=2
	ship.spdy=2
	ship.sprite=1
	ship.bultype="single"
	ship.spreadtime=0
	invul=0
	
	
	
	bullets={}
	ebuls={}
	
	enemies={}
	
	starsetup()
	
	explosions={}
	
	particles={}
	
	shwaves={}
	
	pickups={}
	spreadup=0
	lifeup=0
	
	bombwaves={}
	
	floats={}
	
	flamespr=5
	muzzle=0
	bultimer=0
	attackfreq=60
	nextfire=0
	
	gamestate={score=0,
												lives=4,
												totallives=4,
												bombs=4,
												totalbombs=4}
end
-->8
--helper tab
function starsetup()
	stars={}
	for i=1,50 do
		local newstar={
									x=flr(rnd(128)),
									y=flr(rnd(128)),
									spd=rnd(1.5)+0.5,
									col=7}
		add(stars,newstar)
	end
end

function shootcheck()
	if btn(5) then
		if bultimer<=0 then
			newbullets=getbullets()
			for i=1,#newbullets do
				local bul=newbullets[i]
				add(bullets,bul)
			end
			sfx(0)
			muzzle=4
			bultimer=4
		end
	end
	bultimer-=1
	if #bullets>0 then
		for bullet in all(bullets) do
			move(bullet)
			if bullet.y<-8 then
				del(bullets,bullet)
			end
		end
	end
end

function movepickups()
	for pickup in all(pickups) do
		move(pickup)
		if pickup.y>128 then
				del(pickups,pickup)
			end
	end
end

function shipxpickupcol()
	for pickup in all(pickups) do
		if col(pickup,ship) then
			del(pickups,pickup)
			plogic(pickup)
			sfx(1)
			make_shwave(pickup.x+4,pickup.y+4,7)
		end	
	end
end

function moveenbuls()
	if #ebuls>0 then
		for myebul in all(ebuls) do
			move(myebul)
			animate(myebul)
			if myebul.y>128 or myebul.y<-8 then
				del(ebuls,myebul)
			end
			if myebul.x>136 or myebul.x<-8 then
				del(ebuls,myebul)
			end
		end
	end
end

function bullet_col()
	for myen in all(enemies) do
		for mybul in all(bullets) do
			if col(mybul, myen) then
				del(bullets,mybul)
				if myen.mission!="flyin" then
					myen.hp -= 1
				end
				sfx(5)
				if myen.boss then
					myen.flash=4
				else
					myen.flash=2
				end
				make_shwave(mybul.x+4,mybul.y+4)
				makespark_small(mybul.x+4,mybul.y+4)
				if myen.hp <=0 then
					killen(myen)
				end
			end
		end
	end
end

function explode(expx,expy,isblue)
	local mypbig={}
	mypbig.x=expx
	mypbig.y=expy
	mypbig.spdx=0
	mypbig.spdy=0
	mypbig.age=0
	mypbig.maxage=0
	mypbig.size=10
	mypbig.blue=isblue
	add(particles,mypbig)
	
	for i=1,30 do
		local myp={}
		myp.x=expx
		myp.y=expy
		myp.spdx=(rnd()-0.5)*6
		myp.spdy=(rnd()-0.5)*6
		myp.age=rnd(3)
		myp.maxage=10+rnd(10)
		myp.size=1+rnd(4)
		myp.blue=isblue
		add(particles,myp)
	end
	for i=1,20 do
		local myp={}
		myp.x=expx
		myp.y=expy
		myp.spdx=(rnd()-0.5)*10
		myp.spdy=(rnd()-0.5)*10
		myp.age=rnd(3)
		myp.maxage=10+rnd(10)
		myp.size=1+rnd(4)
		myp.blue=isblue
		myp.spark=true
		add(particles,myp)
	end
	make_shwave_big(expx,expy)
end

function make_shwave(shx,shy,shcol)
	local mysw={}
	if shcol==nil then
		shcol=5
	end
	mysw.x=shx
	mysw.y=shy
	mysw.r=2
	mysw.tr=4
	mysw.col=shcol
	mysw.spd=1
	add(shwaves,mysw)
end

function make_shwave_big(shx,shy)
	local mysw={}
	mysw.x=shx
	mysw.y=shy
	mysw.r=3
	mysw.tr=20
	mysw.col=6
	mysw.spd=2.5
	add(shwaves,mysw)
end

function make_shwave_bomb(shx,shy)
	local bwave={}
	bwave.x=shx
	bwave.y=shy
	bwave.r=3
	bwave.colw=bwave.r*2
	bwave.colh=bwave.r*2
	bwave.tr=30
	bwave.col=7
	bwave.spd=2.8
	add(bombwaves,bwave)
	shake=5
end

function bwavexencol()
	for bwave in all(bombwaves) do
		local offset=bwave.r
		for myen in all(enemies) do
			if col(bwave,myen,offset) then
				myen.hp-=1
				myen.flash=2
				if myen.hp<=0 then
					killen(myen)
				end
			end
		end
		for myebul in all(ebuls) do
			if col(bwave,myebul,offset) then
				del(ebuls,myebul)
			end
		end
	end
end

function makespark_small(sx,sy)

	local myp={}
	myp.x=sx
	myp.y=sy
	myp.spdx=(rnd()-0.5)*10
	myp.spdy=(rnd()-1)*3
	myp.age=rnd(3)
	myp.maxage=10+rnd(10)
	myp.size=1+rnd(4)
	myp.blue=isblue
	myp.spark=true
	add(particles,myp)

end

function getbullets()
	local buls = {}
	
	if ship.bultype=="single" then
		local mybul=makespr()
		mybul.x=ship.x+1
		mybul.y=ship.y
		mybul.spdx=0
		mybul.spdy=-4
		mybul.snd=0
		mybul.sprite=16
		mybul.sprw=1
		mybul.sprh=1
		mybul.colw=6
		mybul.colh=14
		add(buls,mybul) 
	elseif ship.bultype=="spread" then
		local s=-2
		for i=1,3 do
			local mybul=makespr()
			mybul.x=ship.x
			mybul.y=ship.y
			mybul.spdx=s
			mybul.spdy=-4
			mybul.snd=0
			mybul.sprite=16
			mybul.sprw=1
			mybul.sprh=1
			add(buls,mybul) 
			s+=2
		end
	end
	return buls
end

function movecheck()
	if btn(0) then
		ship.x-=ship.spdx
		ship.sprite=2
	end
	if btn(1) then
		ship.x+=ship.spdx
		ship.sprite=3
	end
	if btn(2) then
		ship.y-=ship.spdy
	end
	if btn(3) then
		ship.y+=ship.spdy
	end
	boundscheck()
end

function toggle_weapon()
	if ship.bultype=="single" then
		ship.bultype="spread"
	elseif ship.bultype=="spread" then
		ship.bultype="single"
	end
end

function boundscheck()
	if ship.x>120 then
		ship.x=120
	end
	if ship.x<0 then
		ship.x=0
	end
	if ship.y>=120 then
		ship.y=120
	end
	if ship.y<=0 then
	 ship.y=0
	end
end

function col(a,b,offseta,offsetb)
	if a.ghost or b.ghost then
		return false
	end
	
	if offseta==nil then
		offseta=0
	end
	if offsetb==nil then
		offsetb=0
	end
	--collision math--
	local a_left=a.x-offseta
	local b_left=b.x-offsetb
	local a_top=a.y-offseta
	local b_top=b.y-offsetb
	local a_right=a.x+a.colw-1-offseta
	local b_right=b.x+b.colw-1-offsetb
	local a_bot=a.y+a.colh-1-offseta
	local b_bot=b.y+b.colh-1-offsetb
	
	if a_top > b_bot then return false end
	if b_top > a_bot then return false end
	if a_left > b_right then return false end
	if b_left > a_right then return false end
	return true
end

--collision ship x enemies--
function colshipxen()
	if invul<=0 then
		for enemy in all(enemies) do
			if col(enemy,ship) then		
					explode(ship.x+4,ship.y+4,true)	
					gamestate.lives-=1
					sfx(3)
					invul=60
					shake=12
			end
		end
	else
		invul-=1
	end
end


function makespr()
	local myspr={}
	myspr.x=0
	myspr.y=0
	myspr.spdx=0
	myspr.spdy=0
	myspr.flash=0
	myspr.shake=0
	myspr.aniframe=1
	myspr.sprw=1
	myspr.sprh=1
	myspr.colw=8
	myspr.colh=8
	return myspr
end

function animate(myspr)
	myspr.aniframe+=myspr.anispd
	if flr(myspr.aniframe)>#myspr.ani then
		myspr.aniframe=1
	end
	myspr.sprite=myspr.ani[flr(myspr.aniframe)]	
end

function colshipxebuls()
	if invul<=0 then
		for myebul in all(ebuls) do
			if col(myebul,ship) then
				explode(ship.x+4,ship.y+4,true)
				gamestate.lives-=1
				sfx(3)
				invul=60
				shake=12
			end
		end
	else
		invul-=1
	end
end

function doshake()
	local shakex=rnd(shake)-(shake/2)
	local shakey=rnd(shake)-(shake/2)
	camera(shakex,shakey)
	if shake>10 then
		shake*=0.9
	else
		shake-=1
	end
	
	if shake<1 then
		shake=0
	end
end

function popfloat(fltxt,flx,fly)
	local fl={}
	fl.x=flx
	fl.y=fly
	fl.txt=fltxt
	fl.age=0
	add(floats,fl)
end

function cprint(txt,x,y,c)
	print(txt,x-#txt*2,y,c)
end
-->8
--update tab
-- (hard 30fps)
function update_game()
-- animate ship
	if invul<=0 then
		ship.sprite=1
	end
	if flamespr>9 then
		flamespr=5
	end
	flamespr+=1
	
	--	animate muzzle flash
	if muzzle>0 then
		muzzle-=2
	end
	
	-- keypress checks
	movecheck()
	shootcheck()
	-- movement
	moveenemies()
	--collision
	colshipxen()
	colshipxebuls()
	bullet_col()
	picktimer()
	movepickups()
	moveenbuls()
	shipxpickupcol()
	bwavexencol()
	ship.spreadtime-=1
	if ship.spreadtime<=0 then
		ship.spreadtime=0
		ship.bultype="single"
	end
	if btnp(4) then
		usebomb()
	end
	
	if gamestate.lives<=0 then
		mode="gameover"
		lockout=t+30
		music(6)
		return
	end
	
	if #enemies==0 and mode=="game" then
		ebuls={}
		nextwave()
	end
end

function update_start()
	if btn(5)==false and btn(4)==false then
		btnreleased=true
	end
	
	if btnreleased then
		if btnp(5) or btnp(4) then
			music(-1,1000)
			music(0)
			mode="ready"
			btnreleased=false
		end
	end
end

function update_gameover()
	if	t<lockout then
		return
	end
	if btn(5)==false and btn(4)==false then
		btnreleased=true
	end
	
	if btnreleased then
		if btnp(5) or btnp(4) then
			if gamestate.score>highscore then
				highscore=gamestate.score
				dset(0,highscore)
			end
			startscreen()
			btnreleased=false
		end
	end
end

function update_ready()
end

function update_wavetext()
	update_game()
	wavetime-=1
	if wavetime<=0 then
		mode="game"
		spawnwave()
	end
end

function update_win()
	if	t<lockout then
		return
	end
	if btn(5)==false and btn(4)==false then
		btnreleased=true
	end
	
	if btnreleased then
		if btnp(5) or btnp(4) then
			if gamestate.score>highscore then
				highscore=gamestate.score
				dset(0,highscore)
			end
			startscreen()
			btnreleased=false
		end
	end
	
end
-->8
--draw tab
-- called when 
-- a new frame is drawn
function draw_game()
	cls(0)
	if mode=="wavetext" then
		starfield(3)
	else
		starfield()
	end
	
	if gamestate.lives>0 then
		if invul<=0 then
			drawmyspr(ship)
			spr(flamespr,ship.x,ship.y+8)
		else
			if sin(t/5)<0.1 then
				drawmyspr(ship)
				spr(flamespr,ship.x,ship.y+8)
			end
		end
	end
	drawpickups()
	drawenemies()
	
	drawbuls()
	
	if muzzle>0 then
		circfill(ship.x+3,ship.y-1,muzzle,7)	
		circfill(ship.x+4,ship.y-1,muzzle,7)
	end

	
	draw_shwaves()
	draw_bombwaves()
	drawparticles()
	drawebuls()
	
	drawfloats()
	drawhearts()
	drawbombs()
	print("score:"..makescore(gamestate.score),40,1,12)
	
	spr(29,112,12)
	print(lifeup,121,14,14)
	
	spr(27,112,22)
	print(spreadup,121,24,9)
	
end

function makescore(val)
	if val==0 then
		return 0
	end
	return val.."00"
end

function draw_start()
	cls(0)
	print(version,1,1,1)
	starfield(0.5)
	if highscore>0 then
		cprint("highscore:",64,20,12)
		cprint(makescore(highscore),64,30,12)
	end
	rect(38,49,88,63,7)
	cprint("space blitz",64,54,12)
	spr(1,60,68)
	cprint("- press any key -",64,94,blink())
end

function draw_gameover()
	draw_game()
	cprint("game over",64,55,8)
	cprint("score:"..makescore(gamestate.score),64,70,7)
	if gamestate.score>highscore then
		cprint("new highscore!",64,80,10)
	end
	cprint("- press any key -",64,90,blink(animtable.anykey))
end

function draw_ready()
	cls(0)
	starfield(0.5)
	cprint("ready?",64,55,12)
	local readytext=readycount()
	if readyt<#animtable.ready then
		cprint(readytext,64,64,7)
	end
end

function draw_wavetext()
	draw_game()
	if wave==9 then
		cprint("final wave!",64,50,blink())
	else
		cprint("wave "..wave.." of ".."9",64,50,blink())
	end
end

function draw_win()
	draw_game()
	cprint("you win!",64,55,11)
	cprint("score:"..makescore(gamestate.score),64,70,7)
	if gamestate.score>highscore then
		cprint("new highscore!",64,80,10)
	end
	cprint("- press any key -",64,90,blink(animtable.anykey))
end

function starfield(spd)
	if spd==nil then
		spd=1
	end
	for i=1,50 do
		local star=stars[i]
		
		if star.spd<0.5 then
			star.col=1
		elseif star.spd<1 then
			star.col=13
		elseif star.spd<1.5 then
			star.col=6
		end
		
		pset(star.x,star.y,star.col)
		star.y+=star.spd*spd
		if star.y>128 then
			star.y=0
			star.x=flr(rnd(128))
		end
	end
end

function drawpickups()
	for mypick in all(pickups) do
		local mycol=7
		if t%4<2 then
			mycol=14
		end
		for i=1,15 do
			pal(i,mycol)
		end
		drawoutline(mypick)
		pal()
		drawmyspr(mypick)
	end
end

function drawebuls()
	for myebul in all(ebuls) do
		spr(myebul.sprite,myebul.x,myebul.y)
	end
end

function drawbombs()
	for i=1,gamestate.totalbombs do
		if gamestate.bombs>=i then
			spr(14,9*i+80,1)
		else
			spr(15,9*i+80,1)
		end
	end 
end

function drawhearts()
	for i=1,gamestate.totallives do
		if gamestate.lives>=i then
			spr(11,9*i-8,1)
		else
			spr(12,9*i-8,1)
		end
	end 
end

function drawenemies()
	for myen in all(enemies) do
		if myen.flash>0 then
			
			
			myen.flash-=1
			if myen.boss then
				pal(12,9)
				if t%4<2 then
					pal(6,14)
					pal(13,8)
					pal(5,2)
					pal(1,2)
				end
				
				myen.sprite=204
			else
				for i=1,15 do
					pal(i,7)
				end
			end
		end
		drawmyspr(myen)
		pal()
	end
end

function drawoutline(myspr)
	spr(myspr.sprite,myspr.x+1,myspr.y,myspr.sprw,myspr.sprh)
	spr(myspr.sprite,myspr.x-1,myspr.y,myspr.sprw,myspr.sprh)
	spr(myspr.sprite,myspr.x,myspr.y+1,myspr.sprw,myspr.sprh)
	spr(myspr.sprite,myspr.x,myspr.y-1,myspr.sprw,myspr.sprh)

end

function drawmyspr(myspr)
	local sprx=myspr.x
	local spry=myspr.y
	if myspr.shake>0 then
		myspr.shake-=1
		if t%4<2 then
			sprx+=1
		end
	end
	if myspr.bulmode then
		sprx-=2
		spry-=2
	end
		spr(myspr.sprite,sprx,spry,myspr.sprw,myspr.sprh)
end

function drawbuls()
	for mybul in all(bullets) do
		drawmyspr(mybul)
	end
end

function drawparticles()
	for myp in all(particles) do
		local partcolor=7
		
		if myp.blue then
			partcolor=agepart_blue(myp.age)
		else
			partcolor=agepart_red(myp.age)
		end
		if myp.spark then
			pset(myp.x,myp.y,7)
		else
			circfill(myp.x,myp.y,myp.size,partcolor)
		end
		myp.x+=myp.spdx
		myp.y+=myp.spdy
		myp.spdx=myp.spdx*0.85
		myp.spdy=myp.spdy*0.85
		myp.age+=1
		
		if myp.age>myp.maxage then
			myp.size-=0.5
			if myp.size<0 then
				del(particles,myp)
			end
		end
	
	end
end

function draw_shwaves()
	for mysw in all(shwaves) do
		circ(mysw.x,mysw.y,mysw.r,mysw.col)
		mysw.r+=mysw.spd
		if mysw.r>mysw.tr then
			del(shwaves,mysw)
		end
	end
end

function draw_bombwaves()
	for bwave in all(bombwaves) do
		circ(bwave.x,bwave.y,bwave.r,bwave.col)
		bwave.r+=bwave.spd
		bwave.colw=bwave.r*2
		bwave.colh=bwave.r*2
		if bwave.r>bwave.tr then
			del(bombwaves,bwave)
		end
	end
end

function agepart_red(age)
	local pc = 7
	if age>5 then
		pc=10
	end
	if age>7 then
		pc=9
	end
	if age>10 then
		pc=8
	end
	if age>12 then
		pc=2
	end
	if age>15 then
		pc=5
	end
	return pc
end

function agepart_blue(age)
	local pc = 7
	if age>5 then
		pc=6
	end
	if age>7 then
		pc=12
	end
	if age>10 then
		pc=13
	end
	if age>12 then
		pc=1
	end
	if age>15 then
		pc=1
	end
	return pc
end

function drawfloats()
	for myfl in all(floats) do
		local mycol=7
		if t%4<2 then
			mycol=8
		end
		cprint(myfl.txt,myfl.x,myfl.y,mycol)
		myfl.y-=0.5
		myfl.age+=1
		if myfl.age>60 then
			del(floats,myfl)
		end
	end
end
-->8
--animation tab

--lengthpt = {int,int,int}
--val = {int,int,int}
function animcurve(lengthpts,val)
	local curve={}
	for i=1,#lengthpts do
		for j=1,lengthpts[i] do
			add(curve,val[i])
		end
	end
	return curve
end

function blink()
	local banim=animtable.anykey
	if blinkt>#banim then
		blinkt=1
	end
	return banim[blinkt]
end

function readycount()
	banim=animtable.ready
	if readyt>#banim then
		startgame()
	end
	return banim[readyt]
end
-->8
-- waves and enemies

function spawnwave()
	if wave<9 then
		sfx(6)
	else
		music(14)
	end
	
	if wave==1 then
		attackfreq=60
		placeens({
				{0,1,1,1,1,1,1,1,1,0},
				{0,1,1,1,1,1,1,1,1,0},
				{0,1,1,1,1,1,1,1,1,0},
				{0,1,1,1,1,1,1,1,1,0}
			})
			
	elseif	wave==2 then
		attackfreq=60
		placeens({
				{1,1,2,2,1,1,2,2,1,1},
				{1,1,2,2,1,1,2,2,1,1},
				{1,1,2,2,2,2,2,2,1,1},
				{1,1,2,2,2,2,2,2,1,1}
			})
	elseif	wave==3 then
		attackfreq=60
		placeens({
				{3,3,0,1,1,1,1,0,3,3},
				{3,3,0,1,1,1,1,0,3,3},
				{3,3,0,1,2,2,1,0,3,3},
				{3,3,0,1,2,2,1,0,3,3}
			})
	elseif	wave==4 then
		attackfreq=60
		placeens({
				{0,2,4,2,4,2,4,2,4,0},
				{0,4,1,4,1,4,1,4,1,0},
				{0,2,4,2,4,2,4,2,4,0},
				{0,4,1,4,1,4,1,4,1,0}
			})
	elseif	wave==5 then
		attackfreq=60
		placeens({
				{1,1,1,0,5,0,0,1,1,1},
				{1,1,0,0,0,0,0,0,1,1},
				{1,1,0,1,1,1,1,0,1,1},
				{1,1,0,1,1,1,1,0,1,1}
			})
	elseif	wave==6 then
		attackfreq=60
		placeens({
				{3,3,3,1,1,1,1,3,3,3},
				{5,0,0,2,2,2,2,0,5,0},
				{0,0,0,2,1,1,2,0,0,0},
				{1,1,0,1,1,1,1,0,1,1}
			})
	elseif	wave==7 then
		attackfreq=60
		placeens({
				{6,6,1,1,0,0,1,1,6,6},
				{3,3,1,6,6,6,6,1,3,3},
				{3,3,2,2,2,2,2,2,3,3},
				{3,3,2,2,2,2,2,2,3,3}
			})
	elseif	wave==8 then
		attackfreq=60
		placeens({
				{0,6,4,6,4,6,4,6,4,0},
				{0,4,5,0,5,0,5,0,6,0},
				{0,6,0,0,0,0,0,0,4,0},
				{0,2,2,2,2,2,2,2,2,0}
			})
	elseif	wave==9 then
		attackfreq=300
		placeens({
				{0,0,0,0,0,0,0,0,0,0},
				{0,0,0,7,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0}
			})
	end

end

function placeens(lvl)
	for y=1,#lvl do
		for x=1,10 do
			if lvl[y][x]!=0 then
				spawnen(lvl[y][x],x*12-6,4+y*12,x*3)
			end
		end
	end
end

function nextwave()
	wave+=1
	
	if wave>9 then
		music(4)
		mode="win"
		lockout=t+30
	else
		if wave>1 then
			music(3)	
		end
		mode="wavetext"
		wavetime=80
	end
end

function spawnen(entype,enx,eny,enwait)
	local myen=makespr()
	myen.x=enx*1.25-16
	myen.y=eny-66
	
	myen.posx=enx
	myen.posy=eny
	
	myen.anispd=0.4
	
	myen.wait=enwait
	myen.mission="flyin"
	myen.type=entype

	if entype==nil or entype==1 then
		--frog guy
		myen.sprite=32 
		myen.hp=3
		myen.ani={32,33,34,35,36}
		myen.score=1
	elseif entype==2 then
		--turtle
		myen.sprite=48 
		myen.hp=2
		myen.ani={48,49,50,51,52,53,54,55,56}
		myen.score=2
	elseif entype==3 then
		--mine thingy
		myen.sprite=112 
		myen.hp=4
		myen.ani={112,113,114,115,116,117,118,119,120}
		myen.score=3
	elseif entype==4 then
		--swimming ship
		myen.sprite=96 
		myen.hp=5
		myen.ani={96,97,98,99,100,101,102}
		myen.score=4
	elseif entype==5 then
		--fishbowl 
		myen.sprite=64 
		myen.hp=18
		myen.ani={64,66,68,70}
		myen.sprw=2
		myen.sprh=2
		myen.colw=16
		myen.colh=16
		myen.score=5
	elseif entype==6 then
		--eyeball
		myen.sprite=103 
		myen.hp=6
		myen.ani={103,104,105,106,107,108}
		myen.score=4
	elseif entype==7 then
		--boss
		myen.sprite=192 
		myen.hp=130
		myen.ani=animcurve(
			{10,5,2,5},
			{192,196,200,196}
		)
		--myen.ani={192,196,200,204}
		myen.sprw=4
		myen.sprh=3
		myen.colw=32
		myen.colh=24
		myen.anispd=1
		myen.score=15
		myen.x=48
		myen.y=-24
		
		myen.posx=48
		myen.posy=25
		
		myen.boss=true
		
	end

	add(enemies,myen)
end

function moveenemies()
	for enemy in all(enemies) do
		doenemy(enemy)
		animate(enemy)
		if enemy.mission!="flyin" then
			if enemy.y>128 then
				del(enemies,enemy)
			end
			if enemy.x>136 or enemy.x<-8 then
				del(enemies,enemy)
			end
		end
	end
end


function killen(myen)
	if myen.boss then
		myen.mission="boss4"
		myen.phbegin=t
		myen.ghost=true
		ebuls={}
		music(-1)
		sfx(43)
		return
	end
	
	sfx(4)
	del(enemies,myen)
	explode(myen.x+4,myen.y+4,false)
	
	local pickchance=0.2
	local scoremult=1
	
	if myen.mission=="attack" then
		scoremult=2
		if rnd()<0.5 then
			pickattack()
		end
		pickchance=0.3
		popfloat(makescore(myen.score*scoremult),myen.x+4,myen.y+4)
	end
	gamestate.score+=myen.score*scoremult
	
	if rnd()<pickchance then
		selectpickup(myen)
	end
end

function dropickup(pix,piy,picktype)
	local mypick=makespr()
	mypick.x=pix
	mypick.y=piy
	mypick.spdy=0.75
	mypick.type=picktype
	
	if mypick.type=="life" then
		mypick.sprite=29
	elseif mypick.type=="spreadshot" then
		mypick.sprite=27
	elseif mypick.type=="bomb" then
		mypick.sprite=28
	end
	add(pickups,mypick)
end

function selectpickup(myen)
	local randnum=flr(rnd(100))+1
	local x = myen.x
	local y = myen.y
	
	if myen.boss then
		x=myen.x+15
		y=myen.y+24
	end
	
	if randnum<40 then	
		dropickup(x,y,"life")
	elseif randnum>=40 and randnum<80 then	
		dropickup(x,y,"spreadshot")
	elseif randnum>=80 then	
		dropickup(x,y,"bomb")
	end
end

function plogic(pickup)
	if pickup.type=="life" then
		lifeup+=1
		gamestate.score+=2
		if lifeup>=5 then
			gamestate.score+=90
			sfx(38)
			gamestate.lives+=1
			lifeup-=5
			popfloat("1up!",pickup.x+4,pickup.y+4)
		end
	elseif pickup.type=="spreadshot" then
		spreadup+=1
		gamestate.score+=2
		if spreadup>=5 then
			sfx(37)
			gamestate.score+=90
			spreadup-=5
			ship.spreadtime=300
			ship.bultype="spread"
			popfloat("spreadshot!",pickup.x+4,pickup.y+4)
		end
	elseif pickup.type=="bomb" then
		gamestate.score+=2
		if gamestate.bombs<4 then
			gamestate.bombs+=1
		else 
			gamestate.bombs+=5
		end
	end
end

function usebomb()
	if gamestate.bombs>0 then
		sfx(40)
		invul=45
		gamestate.bombs-=1
		make_shwave_bomb(ship.x+4,ship.y+4)
	else
	sfx(39)
	end
end
-->8
--behaviour

function doenemy(myen)
	if myen.wait>0 then
		myen.wait-=1
		return
	end
	if myen.boss then
		move(myen)
	end
	
	if myen.mission=="flyin" then
		flyin(myen)
	elseif myen.mission=="hover" then
		hover(myen)
	elseif myen.mission=="boss1" then
		boss1(myen)
	elseif myen.mission=="boss2" then
		boss2(myen)
	elseif myen.mission=="boss3" then
		boss3(myen)
	elseif myen.mission=="boss4" then
		boss4(myen)
	elseif myen.mission=="attack" then
		attack(myen)
	end
end

function flyin(myen)
	
	--easing function
	--x+=(targetx-x)/n
	local dx=(myen.posx-myen.x)/7
	local dy=(myen.posy-myen.y)/7
	
	if myen.boss then
		dy=min(dy,1)
	end
	
	myen.x+=dx
	myen.y+=dy
	
	if abs(myen.y-myen.posy)<0.5 then
		myen.y=myen.posy
		myen.x=myen.posx
		if myen.boss then
			sfx(44)
			myen.shake=20
			myen.wait=28
			myen.mission="boss1"
			myen.phbegin=t
		else
			myen.mission="hover"
		end
	end
end

function hover(myen)
	
end

function attack(myen)
	if myen.type==1 then
		myen.spdy=1.7
		myen.spdx=sin(t/45)
		
		if myen.x<32 then
			myen.spdx+=1-(myen.x/32)	
		end
		
		if myen.x>88 then
			myen.spdx-=(myen.x-88)/32	
		end
		
	elseif myen.type==2 then
		myen.spdy=2.5
		myen.spdx=sin(t/15)
		
		if myen.x<32 then
			myen.spdx+=1-(myen.x/32)	
		end
		
		if myen.x>88 then
			myen.spdx-=(myen.x-88)/32	
		end

	elseif myen.type==3 then
		if myen.spdx==0 then
			myen.spdy=2
			if myen.y>=ship.y then
				myen.spdy=0
				if myen.x>ship.x then
					myen.spdx=-2
				else
					myen.spdx=2
				end
			end
		end

	elseif myen.type==4 then
	if t%5==0 then
		myen.spdy=3
	else
		myen.spdy=0
	end
		
	elseif myen.type==5 then
		myen.spdy=0.35
		
		if myen.y>110 then
			myen.spdy=1
		else
			if t%25==0 then
				firespread(myen,8,1.3,rnd())
			end
		end
	elseif myen.type==6 then
		myen.spdy=1
		if t%20>=10 then
			myen.spdx=1
		else
			myen.spdx=-1
		end
		
		if t%30==0 then
			firespread(myen,2,1.3,0.25)
		elseif t%15==0 then
			firespread(myen,2,1.3,0.50)
		end
	end
	move(myen)
end

function picktimer()
	if mode!="game" then
		return
	end
	
	if t>nextfire then
		pickfire()
		nextfire=t+20+rnd(20)
	end
	
	if t%attackfreq==0 then
		pickattack()
	end
end

function pickattack()
	local maxnum=min(10,#enemies)
		
	local myindex=flr(rnd(maxnum))
	myindex=#enemies-myindex
	local myen=enemies[myindex]
	
	if myen==nil then	return end
	
	if myen.mission=="hover" then
		myen.mission="attack"
		if myen.type!=7 then
			myen.anispd*=4
		end
		myen.wait=60
		myen.shake=60
	end
end

function pickfire()
	local maxnum=min(10,#enemies)
	local myindex=flr(rnd(maxnum))
	
	for myen in all(enemies) do
		if myen.type==5 and myen.mission=="hover" then
			if rnd()<0.5 then
				firespread(myen,12,1.2,rnd())
				return
			end
		end
	end
	
	myindex=#enemies-myindex
	local myen=enemies[myindex]
	
	if myen==nil then	return end
	
	if myen.mission=="hover" then
		if myen.type==5 then
			firespread(myen,8,1.2,rnd())
		elseif myen.type==4 or myen.type==2 then
			aimedfire(myen,2)
		else
			fire(myen,0,2)
		end
	end
end

function move(obj)
	obj.x+=obj.spdx
	obj.y+=obj.spdy
end
-->8
--bullets

function fire(myen,ang,spd,bgun)
	local myebul=makespr()
	myebul.x=myen.x+1
	myebul.y=myen.y+6
	
	if myen.type==5 then
	myebul.x=myen.x+5
	myebul.y=myen.y+12
	elseif myen.boss then
		myebul.y=myen.y+15
		if bgun==1 then
			myebul.x=myen.x
		elseif bgun==2 then
			myebul.x=myen.x+26
		end
	end
	
	myebul.spdx=sin(ang)*spd
	myebul.spdy=cos(ang)*spd
	
	if myen.boss then
		myebul.sprite=88
		myebul.ani={88,89,90,89}
		myebul.anispd=0.5
	else 
		myebul.sprite=72
		myebul.ani={72,73,74,73}
		myebul.anispd=0.5
	end
	
	myebul.colw=2
	myebul.colh=2
	myebul.bulmode=true
	
	if myen.boss!=true then
		myen.flash=5
	end
	
	add(ebuls,myebul)
	
	if myen.boss then
		sfx(41)
	else
		sfx(7)
	end
	
	return myebul
end

function firespread(myen,num,spd,base)
	if base==nil then
		base=0
	end
	for i=1,num do
	if myen.boss then
		if t%10>=5 then
			fire(myen,1/num*i+base,spd,1)
		else
			fire(myen,1/num*i+base,spd,2)
		end
	else
		fire(myen,1/num*i+base,spd)
	end
	end	
end

function aimedfire(myen,spd,bgun)
	local ang=atan2((ship.y)-myen.y,(ship.x)-myen.x)

	if myen.boss then
		local myebul1=fire(myen,0,spd,1)
		local myebul2=fire(myen,0,spd,2)
		myebul1.spdx=sin(ang)*spd
		myebul1.spdy=cos(ang)*spd
		myebul2.spdx=sin(ang)*spd
		myebul2.spdy=cos(ang)*spd
	else
		local myebul=fire(myen,0,spd)
		myebul.spdx=sin(ang)*spd
		myebul.spdy=cos(ang)*spd
	end
	
end
-->8
--boss

function boss1(boss)
	--movement
	local spd=2
	if t%35==0 then
		selectpickup(boss)
	end
	if boss.spdx==0 or boss.x>=93 then
		boss.spdx=-spd
	end
	if boss.x<=1 then
		boss.spdx=spd
	end
	--shooting
	if t%15>=7 then
		if t%2==0 then
			fire(boss,0,2,1)
		end
	else
		if t%2==0 then
			fire(boss,0,2,2)
		end
	end
	--transition
	if boss.phbegin+8*30<t and boss.x<=5 then
		boss.mission="boss2"
		boss.phbegin=t
		boss.subphase=1
	end
end

function boss2(boss)
	local spd=1.3
	--movement
	if boss.subphase==1 then
		boss.spdx=-spd
		if boss.x<=3 then
			boss.subphase=2
		end
	elseif boss.subphase==2 then
		boss.spdx=0
		boss.spdy=spd
		if boss.y>=100 then
			boss.subphase=3
		end
	elseif boss.subphase==3 then
		boss.spdx=spd
		boss.spdy=0
		if boss.x>=91 then
			boss.subphase=4
		end
	elseif boss.subphase==4 then
		boss.spdx=0
		boss.spdy=-spd
		if boss.y<=25 then
		--transition
			boss.mission="boss3"
			boss.phbegin=t
			boss.spdy=0
		end
	end
	--shooting
	if t%10==0 then
		aimedfire(boss,spd+0.5)
	end
end

function boss3(boss)
	--movement
	local spd=0.7
	if t%40==0 then
		selectpickup(boss)
	end
	if boss.spdx==0 or boss.x>=93 then
		boss.spdx=-spd
	end
	if boss.x<=3 then
		boss.spdx=spd
	end
	--shooting
	if t%15==0 then
		firespread(boss,8,2,0)
	end
	--transition
	if boss.phbegin+8*30<t then
		boss.mission="boss1"
		boss.phbegin=t
	end
end

function boss4(boss)
	boss.shake=10
	boss.flash=10
	boss.spdx=0
	boss.spdy=0
	
	if t%8==0 then
		explode(boss.x+rnd(32),boss.y+rnd(24))
		sfx(40)
		shake=2
	end
	
	if boss.phbegin+2*30<t then
		if t%5==0 then
			explode(boss.x+rnd(32),boss.y+rnd(24))
			sfx(40)
			shake=2
		end
	end

	if boss.phbegin+4*30<t then
	sfx(42)
		explode_boss(boss.x+16,boss.y+12)
		shake=15
		enemies={}
	end
end

function explode_boss(expx,expy)
	local mypbig={}
	mypbig.x=expx
	mypbig.y=expy
	mypbig.spdx=0
	mypbig.spdy=0
	mypbig.age=0
	mypbig.maxage=0
	mypbig.size=30
	add(particles,mypbig)
	
	for i=1,60 do
		local myp={}
		myp.x=expx
		myp.y=expy
		myp.spdx=(rnd()-0.5)*12
		myp.spdy=(rnd()-0.5)*12
		myp.age=rnd(2)
		myp.maxage=20+rnd(20)
		myp.size=1+rnd(8)
		myp.blue=isblue
		add(particles,myp)
	end
	for i=1,100 do
		local myp={}
		myp.x=expx
		myp.y=expy
		myp.spdx=(rnd()-0.5)*20
		myp.spdy=(rnd()-0.5)*20
		myp.age=rnd(2)
		myp.maxage=20+rnd(20)
		myp.size=1+rnd(4)
		myp.spark=true
		add(particles,myp)
	end
	make_shwave_big(expx,expy)
end
__gfx__
00000000000110000001100000011000000000000000000000000000000000000000000000000000000000000880088008800880000000000000000000000000
00000000001331000013310000133100000000000007700000077000000770000097790000077000000000008878888880088008000000000005500000000000
00700700013333100133b100001b3310000000000097790000077000009779000899998000977900000000008788888880000008000000000058850000000000
0007700001b7cb10017cbb1001bbc710000000000089980000099000008998000088880000899800000000008888888880000008000000000587885000000000
000770001b3cc3b101cc3b1001b3cc10000000000008800000088000000880000000000000088000000000002888888228000082000000000588885000000000
00700700133113310111331001331110000000000000000000088000000000000000000000000000000000000288882002800820000000000658856006000060
00000000013553100155331001335510000000000000000000000000000000000000000000000000000000000028820000288200000000000065560000600600
00000000001991000019910000199100000000000000000000000000000000000000000000000000000000000002200000022000000000000006600000066000
0088000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000b0000000b00000000000000000
087780000089980000000000000000000000000000000000000000000000000000000000000000000000000000000bbb00055bbb00220bbb0000000000000000
8977980008977980000000000000000000000000000000000000000000000000000000000000000000000000e80e83b3005883b3027123b30000000000000000
8977980008979980000000000000000000000000000000000000000000000000000000000000000000000000e80e803805878830021118380000000000000000
0899800000899800000000000000000000000000000000000000000000000000000000000000000000000000e80e80e805888850021118820000000000000000
0899800000088000000000000000000000000000000000000000000000000000000000000000000000000000e80e80e800588500002118200000000000000000
0088000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aa0aa00055000000212000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009909909900000000000020000000000000000000
0000000000d00d00000dd00000d00d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0000d000d00d0000d00d0000d00d000d0000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d5dd5d00d5dd5d00d5dd5d00d5dd5d00d5dd5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05d22d5005d22d5005d22d5005d22d5005d22d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2dd2d22d2dd2d22d2dd2d22d2dd2d22d2dd2d20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2dddddd22dddddd22dddddd22dddddd22dddddd20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2b00b2dd2b00b2dd2b00b2dd2b00b2dd2b00b2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052dd250000000000520025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b0000000b00000000b00000b08000008b80000080b00000b00000000b0000000b000000000000000000000000000000000000000000000000000000000000
0b353b000b5350000b35300000535b00003530000b53500000353b0000535b000b353b0000000000000000000000000000000000000000000000000000000000
03535300053535b00353538005353580b35353b08535350083535300b53535000353530000000000000000000000000000000000000000000000000000000000
05353500b3535300b53535b0b353530005353500035353b0b53535b0035353b00535350000000000000000000000000000000000000000000000000000000000
b35353b00535358003535380053535b003535300b53535008353530085353500b35353b000000000000000000000000000000000000000000000000000000000
0035300000535b000b3530000b5350000b353b0000535b0000353b000b5350000035300000000000000000000000000000000000000000000000000000000000
008b800000b080000000b000000b0000000b0000000b000000b000000080b000008b800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ee000000ee0000007700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000e22e0000e88e00007cc70000000000000000000000000000000000000000000
0000001101100000000000110110000000000011011000000000001101100000e2e82e00e87e8e007c77c7000000000000000000000000000000000000000000
0000112c1c210000000011c21c210000000011c21c210000000011c21c210000e2882e00e8ee8e007c77c7000000000000000000000000000000000000000000
0001212c22cc10000001c12c226c10000001c12c22cc10000001c12c22c610000e22e0000e88e00007cc70000000000000000000000000000000000000000000
0001c2cc2c2cc100000122cc2c2cc100000126cc2c2cc10000012ccc2c2cc10000ee000000ee0000007700000000000000000000000000000000000000000000
00126ccc2c6cc2100012cccc2ccc22100012c2cc2cc622100012c2c62ccc22100000000000000000000000000000000000000000000000000000000000000000
00012cc222cc2100000126c222ccc10000012cc222ccc10000012cc222ccc1000000000000000000000000000000000000000000000000000000000000000000
0012cc27272cc210001c2c272726c210001c2c27272cc210001c2c27272cc21000cc000000cc0000007700000000000000000000000000000000000000000000
0001c6c222cc11000001ccc222cc11000001ccc222cc110000016cc222cc11000c11c0000cddc000078870000000000000000000000000000000000000000000
00001ccc2cc61000000012c62cc21000000012cc26c21000000012cc2cc21000c1a91c00cd7adc00787787000000000000000000000000000000000000000000
0000122c2cc2100000001c2c2ccc100000001c2c2ccc100000001c2c2ccc1000c1991c00cdaadc00787787000000000000000000000000000000000000000000
00000112112100000000011211210000000001121121000000000112112100000c11c0000cddc000078870000000000000000000000000000000000000000000
000000010010000000000001001000000000000100100000000000010010000000cc000000cc0000007700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000010000000000000000000000000000000000000000001000010000000000000000000000000000000000000000000000000000000000000000000000000
15111151011111100011110000111100001111000111111015111151000220002002200202022020000220000202202020022002000000000000000000000000
16655661156556510165561000655600016556101565565116655661202222022022220220277202222772222027720220222202000000000000000000000000
16579561165795611557955101579510155795511657956116579561022772200277772002778720027887200278772002777720000000000000000000000000
15699651166996611669966115699651166996611669966115699651027007200780087007800870078008700780087007800870000000000000000000000000
01566510155665511656656116566561165665611556655101566510022772200277772002787720027887200277872002777720000000000000000000000000
01611610016116101561165115611651156116510161161001611610202222022022220220277202222772222027720220222202000000000000000000000000
00100100001001000110011001100110011001100010010000100100000220002002200202022020000220000202202020022002000000000000000000000000
00111100001111000011110007c1110007c7c7c000111c7000111100001111000011110000000000000000000000000000000000000000000000000000000000
0133331071333310713333107cb3331001bcbc1001333bc701333317013333100133331000000000000000000000000000000000000000000000000000000000
13bbbb31cbbbbb31cbbbbb31cbbbbb3113bbbbb113bbbbbc13bbbbbc13bbbbbc13bbbb3100000000000000000000000000000000000000000000000000000000
011781100c1781107c17811c7c17811c01178110c11781c7c11781c7011781c70117811000000000000000000000000000000000000000000000000000000000
01188110011881c0c11881c7c11881c7011881107c18811c7c18811c7c1881100118811000000000000000000000000000000000000000000000000000000000
13bbbb3113bbbbbc13bbbbbc13bbbbbc1bbbbb31cbbbbb31cbbbbb31cbbbbb3113bbbb3100000000000000000000000000000000000000000000000000000000
01333310013333170133331701333bc701cbcb107cb3331071333310013333100133331000000000000000000000000000000000000000000000000000000000
00111100001111000011110000111c700c7c7c7007c1110000111100001111000011110000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001111110000000000000000000000000011111100000000000000000000000000111111000000000000000000000000001111110000000000000
0000000000011cccccc11000000000000000000000011cccccc11000000000000000000000011cccccc11000000000000000000000011cccccc1100000000000
00000000001ccc777cccc1000000000000000000001ccc777cccc1000000000000000000001ccc777cccc1000000000000000000001ccc777cccc10000000000
0000000001ccc777cccccc10000000000000000001ccc777cccccc10000000000000000001ccc777cccccc10000000000000000001ccc777cccccc1000000000
000000001cccccccccccccc100000000000000001cccccccccccccc100000000000000001cccccc11cccccc100000000000000001cccccccccccccc100000000
00000001ccc7cccccccccccc1000000000000001ccc7ccc11ccccccc1000000000000001ccc7c1cbbc1ccccc1000000000000001ccc71cc11cc1cccc10000000
00000011cc77ccc11ccccccc1100000000000011cc77cccbbccccccc1100000000000011cc77c111111ccccc1100000000000011cc77c1c88c1ccccc11000000
00000171c77ccccbbccccccc1710000000000171c77cc111111ccccc1710000000000171c77cccc11ccccccc1710000000000171c77ccc1111cccccc17100000
000017d1c7ccc111111ccccc1d710000000017d1c7ccccc11ccccccc1d710000000017d1c7cccc1111cccccc1d710000000017d1c7ccccc11ccccccc1d710000
00117d21c7ccc1c11c1ccccc12d7110000117d21c7cccc1111cccccc12d7110000117d21c7cccc1cc1cccccc12d7110000117d21c7cccc1111cccccc12d71100
01661d21cccccc1111cccccc12d1661001661d21cccccc1cc1cccccc12d1661001661d21ccccc11cc11ccccc12d1661001661d21ccccc11cc11ccccc12d16610
1676d121cccccc1cc1cccccc121676d11676d121ccccc11cc11ccccc121676d11676d121ccccccc11ccccccc121676d11676d121cccc11cccc11cccc121676d1
1676d112ccccc11cc11ccccc211676d11676d112ccccccc11ccccccc211676d11676d112cccccc1111cccccc211676d11676d112ccccccc11ccccccc211676d1
1676d1d12cccccc11cccccc21d1676d11676d1d12ccccc1111ccccc21d1676d11676d1d12cccc111111cccc21d1676d11676d1d12ccccc1111ccccc21d1676d1
1676d1dd12cccc1111cccc21dd1676d11676d1dd12ccc111111ccc21dd1676d11676d1dd12cc11111111cc21dd1676d11676d1dd12ccc111111ccc21dd1676d1
1766d1d6d12cccc11cccc21d6d1766d11766d1d6d12ccc1111ccc21d6d1766d11766d1d6d12cc111111cc21d6d1766d11766d1d6d12ccc1111ccc21d6d1766d1
1755d1d66d122cccccc221d66d1755d11755d1d66d122cc11cc221d66d1755d11755d1d66d122c1111c221d66d1755d11755d1d66d122cc11cc221d66d1755d1
15bb51d666d1122222211d666d15bb5115bb51d666d1122222211d666d15bb5115bb51d666d1122222211d666d15bb5115bb51d666d1122222211d666d15bb51
15335157662221111112226675153351153351576622211111122266751533511533515766222111111222667515335115335157666dd111111dd66675153351
0155101576292dddddd29267510155100155101576292dddddd29267510155100155101576292dddddd29267510155100155101576626dddddd6266751015510
00110001572a26666662a2751000110000110001572a26666662a2751000110000110001572a26666662a2751000110000110001572226666662227510001100
0000000015ddd777777ddd51000000000000000015ddd777777ddd51000000000000000015ddd777777ddd510000000000000000152227777772225100000000
00000000015555555555551000000000000000000155555555555510000000000000000001555555555555100000000000000000015555555555551000000000
00000000001111111111110000000000000000000011111111111100000000000000000000111111111111000000000000000000001111111111110000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000
00880088000880088000880088000880088000000cc00cc00cc0ccc0ccc00000ccc0000000000000000000000000000000000000000000000000000000000000
0887888880887888880887888880887888880000c000c000c0c0c0c0c0000c00c0c0000000000000000000000000550000000550000000550000000550000000
0878888880878888880878888880878888880000ccc0c000c0c0cc00cc000000c0c0000000000000000000000005885000005885000005885000005885000000
088888888088888888088888888088888888000000c0c000c0c0c0c0c0000c00c0c0000000000000000000000058788560058788500058788500058788500000
0288888820288888820288888820288888820000cc000cc0cc00c0c0ccc00000ccc0000000000000000000000058888500058888500058888500058888500000
002888820002888820002888820002888820d0000000000000000000000070000000000000000000000000000065885600065885600065885600065885600000
00028820000028820000028820000028820000000000000000000000000000000000000000000000000000000006556000006556000006556000006556000000
00002200000002200000002200000002200000000000000000000000000000000000000000000000000000000000660000000660000000660000000660000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220bbb00000000
00000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000027123b30eee0000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021118380e0e0000
00000000000000000000d00d00000000d00d06000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d0000021118820e0e0000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d0000002118200e0e0000
0000000000000000000d5dd5dd00000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000212000eee0000
00000000000000000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000000200000000000
0000000000000000002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d2000000000000000000
0000000000000000002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd2000000000000000000
000000000000000000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d00000000b000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbb00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e80e83b309990000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e80e803809090000
0000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000e80e80e809090000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e80e80e809090000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d0000aa0aa0aa09990000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00009909909900000000
0000000000000000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d0000000000000000000
00000000000000000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d500d0005d22d50000000000000000000
0000000000000000002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200062d2dd2d200002d2dd2d2000000000000000000
0000000000000000002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd2000000000000000000
000000000000600000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000000000000000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000000000000000
0000000000000000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d0000000000000000000
00000000000000000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000000000000000000
0000000000000000002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d2000000000000000000
0000000000000000002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd2000000000000000000
000000000000000000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000000000000000
00000000000000000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000d00d00000000000000000000
0000000000000000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d000000d5dd5d0000000000000000000
00000000000000000005d22d50000005d22d50000065d22d50000005d22d50000005d22d50000005d22d50000005d22d50000005d22d50000000000000000000
0000000000000000002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d200002d2dd2d2000000000000000000
0000000000000000002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd200002dddddd2000000000000000000
000000000000000000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d0000d2b00b2d000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000
00000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000d0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000013310000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000133331000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000001b7cb1000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001b3cc3b100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001331133100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000135531000000000000000000000000000000d00000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000019910000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000097790000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000089980000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000
000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000060000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000e22e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000e2e82e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000e2882e0000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000

__sfx__
000100002e5302a5302753024530215301e5301c530195301653014530115300f5300d5300b530000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
0101000000000040000400005000050000600006055090550d05514055170551a0551a0550100501005190551605512055160551e0551e055180551e055220550d0050f005130051a00025000000000000000000
51010000075520e5520e5520e5520e552155521a5521a5521d5521e55220552225521b50015500165000000000000000000000000000085000850008500075000000000000175000000000000000000000000000
010100001e5501b55019550185501655014550135501255017500175001650015550145501355011550105500f5500e5500d5500c5500b5000a500095000a5500a55008550065500455003550025500155001550
010100002a65007650225501665007550056300662008620086200662004650026200060000600006200063018600196000063001630046300060000600006000060000600006000060000600006000060000600
000100000765016650007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
110500002d5522c5522a55229552275522555223552205521f5521d5521c5421b5421954218542175421654215532145321353212532105320f5320d5220c5220b52208522075220652204522035220151200512
910200001935213352083020a3520735204352033521d300223002230022300223002230000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010a00000c4200c4200c4200c4200c4200c4200c4200c4200f4200f4200f4200f4200f4200f4200f4200f42010420104201042010420104201042010420104201442014420144201442014420144201442014420
011000001f5501f5501b5501d5501d550205501f5501f5501b5501a5501b5501d5501f5501f5501b5501d5501d550205501f5501b5501a5501b5501d5501f5502755027550255502355023550225502055020550
011000000f5500f5500a5500f5501b550165501b5501b550165500f5500f5500a5500f5500f5500a550055500a5500e5500f5500f550165501b5501b550165501755017550125500f5500f550125501055010550
011000001e5501c5501c550175501e5501b550205501d550225501e55023550205501c55026550265500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000017550145501455010550175500b550195500d5501b5500f5501c550105500455016550165500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00001b000000001b0001d0001b030000001b0201d0201e0302003020040200401e00020000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050d00001f500000001f500215001f530000001f52021520225302453024530245302250024500245002450000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00002200000000220002400022030000002203024030250302703027030270302500027000270002700000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d1000002b0202b0202b0202b0202b0202b0202b0202b0202b020290202b0202c0202b0202b0202b0202602026020260202702027020270202b0202b0202b0202a0302a0302a0302703027030270302003020030
4d1000002003028030280302c0302a0302a0302a0302703027030270302c0302a030290302e0302e0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001e050000001e0501d0501b0501a0601a0621a062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050f00001b540000001b5401a54018540175501755217562000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000290502c0002a00029055290552a000270502900024000290002705024000240002400027050240002a05024000240002a0552a055240002905024000240002400029050240002a000290002405026200
510c00001431519315203251432519315203151432519325203151431519325203251431519315203251432519315203151432519325203151431519325203251431519315203251432519315203151432518325
010c00000175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750
010c0000195502c5002a50019555195552a500185502950024500295001855024500245002450018550245001b55024500245001b5551b555245001955024500245002450019550245002a500295001855026500
010c0000290502c0002a00029055290552a000270502900024000290002000024000240352504527050240002a050240002f0052d0552c0552400029050240002400024000240002400024030250422905026200
901000001173518735167351673513735137351373513735000001373513735000001373513735117351373513735137351373516735157351673516735167351673516735167351673516735187351b7351b735
001000000753307500075000753307500075000753307500075000753307500075330750007500075330750007500075330750007500075330750007533075330750007500075330750007500075330000007533
90100000117350c7350c7350c7050c7350c7050c7350f7351173013735137350f7300c7350c7350c7350c7350a7350c7350c7350c7050c7350c7050c7350c7350f7350f7350f7350c7350a73507735077350a735
010c0000195502c5002a50019555195552a500185502950024500295002050024500145351654518550245001b550245002f5051e5551d5552450019550245002450024500245002450014530165401955026500
010c00002c05024000240002a05529055240002e050240002400029000270502400024000240002e050240003005024000240002e0552d05524000300502400024000290002905024000270002a0002900028000
510c0000143151931520325143251931520315163251932516315183151932516325183151931516325183251b3151e315183251b3251e315183151b3251e325183151b3151d325183251b3151d315183251b325
010c00000175001750017500175001750017500175001750037500375003750037500375003750037500375006750067500675006750067500675006750067500575005750057500575005750057500575005750
010c00001d55024500245001b55519555245001e550245002450029500165502450024500245001e550245001e55024500245001d5551b555245001d5502450024500295001855024500275002a5002950028500
00060000010501605019050160501905001050160501905016050190601b0611b0611b061290001d000170002600001050160501905016050190500105016050190501b0611b0611b0501b0501b0401b0301b025
00060000205401d540205401d540205401d540205401d54022540225502255022550225500000000000000000000025534225302553022530255301d530255302253019531275322753027530275322753027530
000600001972020720227201b730207301973020740227401b74020740227402274022740000000000000000000001672020720257201b730257301973025740227401b740277402274027740277402774027740
010a00000532105320053200532005320053200532005320083200832008320083200832008320083200832009320093200932009320093200932009320093200d3200d3200d3200d3200d3200d3200d3200d320
0b0500000435206352093520c3521130101352053520b3520d35239300383003630034300313002e30029300253001f3001a30016300123000e30000300003000030000300003000030000300003000030000300
0003000007751097510b7510d7510f75113751177511b751207512475129751000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000544005420054200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e0300001d665236652366523665236652366522655206551f6551e6551d6551b6551a6551965517655166551465512655106450d6450a6450864507645066450564503645026450064500635006350162500600
010100000315503155031520e155101550d155031051510319100141000f1000b1000b10000100121000b10000100001000010000100001000010000100001000010000100001000010000100001000010000100
0204000035650276402f650186202a6502965027650256502465021650206501e6501c6501b6501a6501965018650166501565013650116400f6400e6400e6400c6400a630096300762006620046200265000650
58040000081311c171161710f17107171131710d17105171031610c161101510a1510814108141071410514104132041320313203132031320313202132021320213202132011320112200122001220012200122
5c03000016131261312b1413015119151361513715138151141512414134141301412c14127142231421e1421b1421813216132131321d1320f1320d1320b1320913208132061220512204122031220212201120
000a002034615296152b6161e6061c6401d6452b6152760528615296152b6151e6001c6401d6452b6152761534615296152b6161e6061c6401d6452b6152760528615356152b6151e6051c6401d6452b61527615
050a00200232002320023200232002320023200232002320023200230502325023250232002325023200232503320033200332003320033200332003320033200732007320073200732007320073200732007320
010a000002320023200232002320023200232002320023200a3200a3200a3200a3200a3200a3200a3200a32005320053200532005320053200532005320053200332003320033200332003320033200332003320
010a000009220092200922009220092200922009220092200e2200e2200e2200e2200e2200e2200e2200e2200a2200a2200a2200a2200a2200a2200a2200a2200022000220002200022001220012200122001220
010a000005220052200522005220052200522005220052200e2200e2200e2200e2200e2200e2200e2200e2200a2200a2200a2200a2200a2200a2200a2200a2200022000220002200022001220012200122001220
010a00000d2200d2200d2200d2200d2200d2200d2200d220052200522005220052200522005220052200522011220112201122011220112201122011220112200322003220032200322003220032200322003220
150a00001522015220152201522015220152201522015220152201522015220152201322013220152201522016220162201622016220162201622016220162201922019220192201922019220192201922019220
150a00001a2201a2201a2201a2201a2201a2201a2251a2251d2201d2201d2201d2201d2201d2201d2201d22019220192201922019220192201922019220192201622016220162201622016220162201622016220
150a0000192201922019220192201922019220192251922511220112201122011220112201122011220112201d2201d2201d2201d2201d2201d2201d2201d22018220192211a2211d22121221252212622126221
090a00001d2171a217212172221729217262172d2172e2171d2171a2172121722217112170e21715217162171d2171a217212172221729217262172d2172e2171d2171a2172121722217112170e2171521716217
090a000029217262172d2172e2173521732217392173a21729217262172d2172e2171d2171a2172121722217112170e21715217162171d2171a2172121722217112170e21715217162170521702217092170a217
010a00000e003296000e0031e600286151d6052b605276150e003296052b6151e600286151d6452b615276051f6501f6301f6201e6001f6251f6251f625276050e003356052b6051e605106111c6112862133631
__music__
04 21222344
00 090a4344
04 0b0c4344
04 0d0e0f44
00 100a4344
04 110c4344
04 12134344
01 591a4344
00 191a4344
00 591a4344
02 1b1a4344
01 14151617
00 1815161c
02 1d1e1f20
00 08246844
01 2d2e2f44
00 2d2f3066
00 2d2e3165
00 2d313265
00 2d2e3344
00 2d303444
00 2d2e3344
00 2d313544
00 2f303644
00 2f303744
00 2e323644
02 24083844

