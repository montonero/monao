
-- プレーヤー

module Player (
	Player(..),
	newPlayer,
	updatePlayer,
	renderPlayer
) where

import Multimedia.SDL

import Util
import SDLUtil
import Const
import Field


maxVx = one * 3
maxVy = one * 8
acc = one `div` 6
jumpVy = -17 * gravity


data Player = Player {
	x :: Int,
	y :: Int,
	vx :: Int,
	vy :: Int,
	stand :: Bool,

	lr :: Int,
	pat :: Int,
	anm :: Int
	}

newPlayer = Player {
	x = 1 * chrSize * one,
	y = 1 * chrSize * one,
	vx = 0,
	vy = 0,
	stand = False,

	lr = 1,
	pat = 0,
	anm = 0
	}


patStop = 0
patWalk = 1
walkPatNum = 3
patJump = patWalk + walkPatNum

imgTable = [
	[ImgNario00, ImgNario01, ImgNario02, ImgNario03, ImgNario04],
	[ImgNario10, ImgNario11, ImgNario12, ImgNario13, ImgNario14]
	]


-- 横移動
moveX :: KeyProc -> Player -> Player
moveX kp player =
	if (stand player)
		then player' { lr = lr', pat = pat', anm = anm' }
		else player'
	where
		ax = (-padl + padr) * acc
		vx'
			| ax /= 0	= rangeadd (vx player) ax (-maxspd) maxspd
			| otherwise	= friction (vx player) acc
		x' = (x player) + vx'
		padl = if isPressed (kp PadL) then 1 else 0
		padr = if isPressed (kp PadR) then 1 else 0
		maxspd
			| isPressed (kp PadB)	= maxVx * 2
			| otherwise				= maxVx

		player' = player { x = x', vx = vx' }

		lr' =
			case (-padl + padr) of
				0	-> lr player
				-1	-> 0
				1	-> 1
		pat'
			| vx' == 0		= patStop
			| otherwise		= (anm' `div` anmCnt) + patWalk
		anm'
			| vx' == 0		= 0
			| otherwise		= ((anm player) + (abs vx')) `mod` (walkPatNum * anmCnt)
		anmCnt = maxVx * 3


cellCrd :: Int -> Int
cellCrd x = x `div` (chrSize * one)


-- ジャンプ中
jump :: Field -> Player -> Player
jump fld player =
	player { y = y', vy = vy', stand = stand' }
	where
		vytmp = min maxVy $ (vy player) + gravity
		ytmp = (y player) + vytmp

		y' = if isGround ytmp then yground ytmp else ytmp
		vy' = if isGround ytmp then 0 else vytmp
		stand' = isGround ytmp

		isGround y = isBlock $ fieldRef fld (cellCrd (x player)) (cellCrd y)
		yground y = (cellCrd y) * (chrSize * one)


-- 通常時：地面をチェック
checkFall :: KeyProc -> Field -> Player -> Player
checkFall kp fld player =
	player { stand = stand', vy = vy', pat = pat' }
	where
		ytmp = (y player) + one

		stand'
			| isGround ytmp		= not dojump
			| otherwise			= False		-- 落下開始
		vy'
			| not stand' && dojump	= jumpVy
			| otherwise				= 0
		pat'
			| dojump	= patJump
			| otherwise	= pat player

		dojump = kp PadA == Pushed

		isGround y = isBlock $ fieldRef fld (cellCrd (x player)) (cellCrd y)
		yground y = (cellCrd y) * (chrSize * one)


updatePlayer :: KeyProc -> Field -> Player -> Player
updatePlayer kp fld player =
	moveY $ moveX kp player
	where
		moveY
			| (stand player)	= checkFall kp fld
			| otherwise			= jump fld


renderPlayer sur player imgres = do
	blitSurface (getImageSurface imgres imgtype) Nothing sur pos
	where
		pos = pt ((x player) `div` one - chrSize `div` 2) ((y player) `div` one - chrSize)
		imgtype = imgTable !! (lr player) !! (pat player)