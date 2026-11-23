pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- zumbi city
-- setas: andar/dirigir
-- c: telefone / porta / carro
-- espaco ou x: atirar / freio
-- z: trocar arma

gc=split("12,11,8")
dc=split("1,3,2")
mc=split("6,5,1,0,3,3,12,13,5,5")
dk={split("0,1,2,3,4,5,13,6,8,9,9,11,13,13,14,14"),split("0,0,1,1,2,1,13,6,2,4,9,3,13,1,2,14")}
vx=split("0,13,29,44,59,72")
hy=split("0,11,26,41,56,72")
zn={"fffrff","hTTrTf","pTTrTf","hTirTf","cTTrpf","fffrff"}
rf=split("12,1,4,11,3,4,8,2,4,9,4,4,4,2,4,14,2,4,13,5,4,8,2,170,8,2,186,8,2,202,8,2,218,13,5,234")
phones={{x=100,y=44,g=0},{x=260,y=364,g=1},{x=500,y=204,g=2}}
gs,dia=0,0
lv=0
bat=1
wp=1
fh=1
am=split("0,0,0,0,0,0,0,0")
cartdata("zumbi_city3")
poke(0x5f2d,1)
if dget(4)==1 then
 mon,bat,dia=dget(0),dget(1)|1,dget(2)
 for i=5,8 do am[i]=dget(i) end
end

-- troca uma cor respeitando a noite
function pl(c,v)
 pal(c,lv>0 and dk[lv][v+1] or v)
end

-- colisao a pe (px,py = centro)
function bc(x,y)
 local n=0
 for i=-3,2,5 do
  for j=-1,3,4 do
   if sol(x+i,y+j) or cbx(x+i,y+j,0) then n+=1 end
  end
 end
 return n
end

function dd(a,b)
 return dist(a.x,a.y,b.x,b.y)
end

function dq(o)
 return dist(o.x,o.y,px,py)
end

function _init()
 if not T then gen() end
 ccx=nil
 px,py,face,cd,fu,fw=12,52,0,0,1,0
 tm=tm or 0
 hp,heat,wl,mt,inv,sw,fm,vs=100,0,0,240,0,0,100,0
 mon=mon or 0
 msg="telefone = ponto no minimapa"
 P,C,S,Q,B,F,CN,lt={},{},{},{},{},{},{},{}
 drv,dl,ins=nil
 add(C,{x=12,y=61,a=.25,v=0,c=10,t=3,h=100})
 pcars()
 for i=1,24 do spp() end
 -- area reservada: sprites x<80,y>=48 sao o minimapa; ids>=128 dividem memoria com o mapa
 if not mmd then
  mmd=1
  for y=0,79 do
   for x=0,79 do
    local t=tt(x,y)
    sset(x,y+48,t==2 and dc[gng(x*8)+1] or mc[t+1])
   end
  end
 end
end

-- carros sao objetos do mapa: poucos, em ruas retas, afastados.
-- 12% destruidos, 30% trancados, o resto abre. h=vida do carro
function pcars()
 for i=1,600 do
  if #C>=28 then return end
  local x,y=rnd(640),rnd(640)
  if i<99 then x/=3 y/=3 end
  local a,b=ax[x\8],ay[y\8]
  if tt(x\8,y\8)==0 and (a>1)!=(b>1) then
   local g=(a>1 and 0 or .25)+(rnd()<.5 and 0 or .5)+rnd(.06)-.03
   local ok=blk(x,y,g)==0
   for c in all(C) do
    if dist(x,y,c.x,c.y)<30 then ok=false end
   end
   local r=#C*.618%1
   local w=r<.12
   if ok then add(C,{x=x,y=y,a=g,v=0,t=0,c=w and 0 or rnd(split("4,5,13,6,9,2,15")),h=w and 0 or 60+rnd(40),w=w,l=r>.12 and r<.42}) end
  end
 end
end

-- ponto dentro de algum carro parado (so os proximos: CN)
function cbx(x,y,d)
 for c in all(CN) do
  local u,v=x-c.x,y-c.y
  if abs(u)<9 and abs(v)<9 then
   local f,s=cos(c.a),sin(c.a)
   if abs(u*f+v*s)<7 and abs(v*f-u*s)<3 then c.h-=d return true end
  end
 end
end

-- zumbi: so a noite
function spp()
 local x,y=rpos(rnd(2)\1,70,140)
 if lv>0 and x and rnd()>.3 and bc(x,y)<1 then
  local k=flr(rnd()+wl*.12)
  add(P,{x=x,y=y,dx=0,dy=0,hp=2-k+dia\2,t=0,f=3,fl=0,k=k})
 end
end

function sm(s,t)
 msg,mt=s,t
end

-- dano no jogador: o colete absorve primeiro
function hurt(n)
 za=min(vs,n)
 vs-=za
 hp-=n-za
end

function dmg(p,n)
 p.hp-=n
 if p.hp<=0 then kill(p) end
end

function hot(n)
 heat=min(100,heat+n)
end

-- v: morto pelo carro
function kill(p,v)
 sfx(1)
 spl(p.x,p.y)
 fx(p.x,p.y,11,6)
 del(P,p)
 mon+=8
 hot(v and 3 or 1)
 if v then drv.h-=1 end
end

function bump(c)
 local f,s=cos(drv.a),sin(drv.a)
 local dx,dy=c.x-drv.x,c.y-drv.y
 local u,v=abs(cos(c.a-drv.a)),abs(sin(c.a-drv.a))
 if abs(dx*f+dy*s)>6+7*u+3*v or abs(dy*f-dx*s)>2+7*v+3*u then return end
 local sp=abs(drv.v)
 local nx,ny=drv.x-dx*.3,drv.y-dy*.3
 if not sol(nx,ny) then drv.x,drv.y=nx,ny end
 drv.v*=.4
 c.v=0
 if sp>.6 then
  hurt(sp*2)
  dm="acidente de carro"
  sfx(2)
  fx((drv.x+c.x)/2,(drv.y+c.y)/2,10,3)
  drv.h-=sp*5
  c.h-=sp*5
 end
end

-- carro destruido: explode, vira carcaca solida e pega fogo
function wreck(c)
 c.w,c.c,c.v,c.l=1,0,0
 fx(c.x,c.y,9,10)
 fx(c.x,c.y,10,6)
 sfx(2)
 add(F,{x=c.x,y=c.y,l=90,d=30})
 if c==drv then out() end
 if dq(c)<20 then
  hurt(80)
  dm="carro explodiu"
 end
end

function kd(a,b)
 return (btn(a) and 1 or 0)-(btn(b) and 1 or 0)
end

function ctrl()
 local k5=btn(5) or stat(28,44)
 if btnp(4) then
  if not drv and stat(28,29) then cw() cd=12
  else act() end
 end
 if drv then
  if btn(2) then drv.v+=.14 end
  if btn(3) then drv.v-=drv.v>.2 and .2 or .1 end
  if k5 then
   drv.v*=.9
   if abs(drv.v)>1 then fx(drv.x,drv.y,6,1) end
  end
  local sp=abs(drv.v)
  local st=kd(0,1)*.03*mid(sp/.8,.4,1)*(1-mid(sp-2,0,1.2)*.3)*sgn(drv.v)
  local b0=blk(drv.x,drv.y,drv.a)
  if blk(drv.x,drv.y,drv.a+st)<=b0 then
   drv.a+=st
  elseif st!=0 and sp<.5 then
   -- encostado: recua um pouco pra conseguir girar
   local bx,by=drv.x-cos(drv.a)*.5,drv.y-sin(drv.a)*.5
   if blk(bx,by,drv.a)<=b0 and not sol(bx,by) then drv.x,drv.y=bx,by end
  end
  drv.v=mid(drv.v*.97,-1.5,3.2*(.5+drv.h/200))
  mv(drv)
  if drv.hit then
   drv.hit=false
   drv.h-=drv.dmg*6
   if drv.dmg>1.5 then
    hurt(drv.dmg*4)
    dm="acidente de carro"
    sfx(2)
    fx(drv.x,drv.y,10,4)
   end
  end
 else
  local dx=kd(1,0)
  local dy=kd(3,2)
  mov=dx!=0 or dy!=0
  if mov then
   local k=(dx*dy!=0 and .9 or 1.3)*min(1,fm/40+.4)
   dx*=k dy*=k
   local e=bc(px,py)
   if e==0 then lx,ly=px,py end
   if bc(px+dx,py)<max(1,e) then px+=dx end
   if bc(px,py+dy)<max(1,e) then py+=dy end
   if bc(px,py)>2 and lx then px,py=lx,ly end
   if abs(dx)>abs(dy) then face=dx>0 and 0 or 1 fu,fw=sgn(dx),0 else face=dy>0 and 3 or 2 fu,fw=0,sgn(dy) end
  end
  if k5 and cd<=0 then
   local w=fh>0 and 1 or wp
   local o=w*3
   cd=wd[o]
   if w>4 and am[w]<1 then
    cd=10
    sm("sem municao",40)
   elseif w>3 then
    shoot()
   else
    sw=8
    sfx(0)
    hot(.6)
    for p in all(P) do
     if dist(p.x,p.y,px+fu*8,py+fw*8)<10 then
      p.fl=5
      local nx,ny=p.x+fu*6,p.y+fw*6
      if bc(nx,ny)<1 then p.x,p.y=nx,ny end
      dmg(p,wd[o-1]/(1+fh))
     end
    end
   end
  end
 end
end

function _update()
 tm=(tm+1)%18000
 if dia>0 and tm%9000<1 then
  dia+=1
  if dia>7 then dia,dl,di=0,{{"o exercito chegou! voce","sobreviveu aos 7 dias.","fim. obrigado por jogar!"}},1 end
 end
 cd,mt,inv,sw=max(cd-1,0),max(mt-1,0),max(inv-1,0),max(sw-1,0)
 if gs==0 then
  if btnp(4) then
   gs,tm,mt=1,1500,240
   dl,di={{"a cidade foi tomada pelos","zumbis. de dia eles somem;","a noite eles saem."},
{"pedra negra fica longe","de tudo. ache um telefone","e peca ajuda: o exercito","leva 7 dias. sobreviva!"},
{"saqueie casas (c) pra","achar $ e itens. compre","armas, colete e comida."}},1
  end
  return
 end
 if dl then
  if btnp(4) then
   di+=1
   if di>#dl then dl=nil if hp<=0 then mon,bat,gs,wp,dia,am=0,1,0,1,0,split("0,0,0,0,0,0,0,0") _init() end end
  end
  return
 end
 if ins then insd() else ctrl() end
 if drv then px,py=drv.x,drv.y end
 if (lv>0)!=ngt then
  ngt=lv>0
  music(ngt and 0 or -1,1000)
  if not ngt and ins then P={} end
 end
 if ins then return end
 if tm%max(6,18-wl*3)==0 and #P<30+wl*3 then spp() end
 CN={}
 for c in all(C) do
  local d=dq(c)
  if c.h<=0 and not c.w then wreck(c) end
  if d<110 then
   if c!=drv then
    add(CN,c)
    if drv and d<18 then bump(c) end
   end
   if (c.w or c.h<50) and tm%2==0 then
    add(Q,{x=c.x+cos(c.a)*4,y=c.y+sin(c.a)*4,dx=rnd(.6)-.3,dy=-.5,l=14,c=c.w and 8+tm%3 or c.h<25 and 9 or 6})
   end
  end
 end
 -- zumbis
 for p in all(P) do
  local d=dq(p)
  if d>170 or lv==0 and rnd()<.02 then
   del(P,p)
  else
   p.t-=1 p.fl-=1
   local sp=(p.k==1 and .9 or .45)+dia*.04
   local a=atan2(px-p.x,py-p.y)
   if d<60+wl*18 then
    p.dx,p.dy=cos(a)*sp,sin(a)*sp
   elseif p.t<=0 then
    local a=rnd(5)\1*.25
    local m=a<1 and .2 or 0
    p.dx,p.dy=cos(a)*m,sin(a)*m
    p.t=40+rnd(60)
   end
   local nx,ny=p.x+p.dx,p.y+p.dy
   if d<110 then
    for q in all(P) do
     if q!=p and abs(p.x-q.x)<4 and abs(p.y-q.y)<4 then
      nx+=(p.x-q.x)*.15+rnd(.1)-.05
      ny+=(p.y-q.y)*.15+rnd(.1)-.05
     end
    end
   end
   if bc(nx,p.y)<1 then p.x=nx end
   if bc(p.x,ny)<1 then p.y=ny end
   if abs(p.dx)>abs(p.dy) then
    p.f=p.dx>0 and 0 or 1
   elseif p.dy!=0 then
    p.f=p.dy>0 and 3 or 2
   end
   if drv then
    if abs(drv.v)>.8 and d<8 then
     kill(p,true)
    elseif d<9 and abs(drv.v)<.5 then
     hurt(.05)
     drv.h-=.03
     dm="virou zumbi"
    end
   elseif d<7 and inv<=0 then
    hurt(6)
    inv=40
    sfx(3)
    dm="virou zumbi"
    fx(px,py,8,3)
    if bc(px+cos(a)*6,py+sin(a)*6)<1 then
     px+=cos(a)*6
     py+=sin(a)*6
    end
   end
  end
 end
 -- projeteis e fogo
 for b in all(B) do
  b.x+=b.dx b.y+=b.dy b.l-=1
  local h=cbx(b.x,b.y,b.d*9) or sol(b.x,b.y) or b.l<0
  for p in all(P) do
   if dd(p,b)<6 then
    h=true
    if b.t<3 then
     p.fl=5
     dmg(p,b.d)
    end
   end
  end
  if h then
   del(B,b)
   if b.t==3 then
    add(F,{x=b.x,y=b.y,l=12,d=22})
    sfx(2)
   end
  end
 end
 for f in all(F) do
  f.l-=1
  if f.l<0 then del(F,f) else
   for p in all(P) do
    if dd(p,f)<(f.d or 14) then
     dmg(p,f.d and 9 or .04)
    end
   end
   if dq(f)<11 then
    hurt(.15)
    dm="queimado"
   end
   for c in all(C) do
    if dd(c,f)<14 then c.h-=.05 end
   end
  end
 end
 for q in all(Q) do
  q.x+=q.dx q.y+=q.dy q.l-=1
  if q.l<0 then del(Q,q) end
 end
 -- barulho atrai zumbis
 if drv and abs(drv.v)>2.4 then hot(.03) end
 heat=max(0,heat-.04)
 wl=heat\20+dia\2
 hp=min(100,hp+.02)
 fm=max(0,fm-.012)
 if fm<=0 then hp-=.1 dm="fome" end
 if hp<=0 then die(dm or "virou zumbi") end
end

-- personagem (b=16 jogador, 24 zumbi)
function dchar(b,f,x,y,fl,wk)
 local o=f<2 and 4 or f==2 and 2 or 0
 rectfill(x-2,y+3,x+1,y+4,1)
 if fl>0 then
  for c=1,15 do pal(c,7) end
 end
 spr(b+o+(wk and tm\6%2 or 0),x-4,y-4,1,1,f==1)
 if fl>0 then dark(lv) end
end

-- carro: sprite fixo em 16 direcoes
function dcar(c)
 if dq(c)>120 then return end
 local n=flr(c.a%1*16+.5)%16
 local q=n<5 and n or n<9 and 8-n or n<13 and n-8 or 16-n
 local id=q<3 and 106+q*2 or 132+q*2
 pl(14,c.c)
 spr(id,flr(c.x+.5)-8,flr(c.y+.5)-8,2,2,n>4 and n<13,n>8)
 pl(14,14)
end

function dtile(tx,ty)
 local i=tx+ty*80
 local x,y,t,v=tx*8,ty*8,tt(tx,ty),V[i]
 if t==3 then
  -- muralha de contencao fora do mapa
  rectfill(x,y,x+7,y+7,5)
  rect(x,y,x+7,y+7,0)
 elseif t==2 then
  local g=v\256
  v%=256
  pl(8,rf[g*3-2]) pl(2,rf[g*3-1])
  if v==5 and lv>0 and (tx*3+ty)%3>0 then pl(12,10) end
  spr(rf[g*3]+v-4,x,y)
  pl(8,8) pl(2,2) pl(12,12)
  if g==10 and v<7 and tt(tx,ty+1)!=2 then rectfill(x,y,x+7,y+2,tx%2==0 and 8 or 7) end
  if v==6 then
   local k=dr[i]
   if k>1 then
    spr(45+k,x,y-8)
   end
   if lk[i] then rectfill(x+4,y+3,x+5,y+4,8) end
  end
 else
  if t>3 and t!=6 and t!=7 then spr((tx*7+ty*3)%5==0 and 1 or 0,x,y) end
  local q=LT[i] or 0
  if t==6 then v=30+tm\30%2 end
  if q>1 or LT[i+1]==2 then v=12 end
  if v>0 and v!=3 and v!=36 then spr(v==35 and 11 or v,x,y) end
  -- faixa de retencao: so na pista ao lado do semaforo
  if q>2 then
   for j=0,q>4 and 4 or 0,4 do
    if q%2>0 then rectfill(x,y+j,x+7,y+j+1,7) else rectfill(x+j,y,x+j+1,y+7,7) end
   end
  end
  if t==7 then
   for k=-1,1,2 do
    if tt(tx,ty+k)==6 then rectfill(x,y+3+k*3,x+7,y+4+k*3,4) end
   end
  end
 end
end

-- barra de status (y, valor 0-100, cor, rotulo)
function bar(y,v,t,c)
 print(t,1,y,7)
 rectfill(20,y-1,45,y+4,1)
 rectfill(21,y,21+v*.24,y+3,c or v>50 and 11 or v>25 and 10 or 8)
end

function hud()
 local h=drv and 37 or 30
 rectfill(0,0,52,h,0)
 rect(0,0,52,h,5)
 print("$ "..mon,2,2,10)
 if dia>0 then print("dia "..dia.."/7",96,11,8) end
 circfill(47,4,2,lv>0 and 12 or 10)
 rectfill(0,118,56,127,0)
 print(fh>0 and "maos" or wd[wp*3-2]..(wp>4 and " "..am[wp] or ""),3,121,7)
 bar(10,hp,"vida")
 bar(17,vs,"cole",12)
 if drv then
  rectfill(95,0,127,8,1)
  print(flr(abs(drv.v)*30).."km/h",98,2,7)
  bar(31,max(drv.h,0),"carro")
 end
 bar(24,fm,"fome",fm>25 and 9 or 8)
 if mt>0 and not dl then note(msg,40) end
 -- minimapa redondo: letras=predios, seta=jogador, n/s/l/o=bussola
 msx,msy=mid(px\8-12,0,55),mid(py\8-12,0,55)
 circfill(107,104,12,0)
 for j=-11,11 do
  local h=flr(sqrt(150-j*j))
  sspr(msx+12-h,msy+60+j,h*2+1,1,107-h,104+j)
 end
 circ(107,104,12,6)
 spr(64,104,83)
 spr(65,104,119)
 spr(66,87,101)
 spr(67,121,101)
 for p in all(phones) do mp(p,gc[p.g+1]) end
 for p in all(P) do mp(p,8) end
 for p in all(pn) do
  local i,j=mq(p)
  if i*i+j*j>81 then
   local a=atan2(i,j)
   i,j=cos(a)*9,sin(a)*9
  end
  local u,w,c=107+i,104+j,sub("-hemdg",p.k,p.k)
  pr(c,u-1,w-2,cm[p.k])
 end
 local a=drv and drv.a or atan2(fu,fw)
 local u,w=mq{x=px,y=py}
 local k=max(1,dist(0,0,u,w)/9)
 u,w=107+u/k,104+w/k
 for k=-1,1,2 do line(u+cos(a)*3,w+sin(a)*3,u+cos(a+k*.38)*3,w+sin(a+k*.38)*3,tm%8<4 and 7 or 10) end
 if dl then
  local d=dl[di]
  local h=#d*7+16
  pap(10,122-h,108,h)
  for i=1,#d do print(d[i],14,119-h+i*7,1) end
  print("[o]",102,114,8)
 end
end

function title()
 rectfill(0,26,127,114,1)
 pr("zumbi city",44,34,11,3)
 print("\fasetas    \f7andar / dirigir\n\n\faespaco   \f7atirar / freio\n\n\faz         \f7trocar arma\n\n\fac         \f7casa / carro",16,54,7)
 if tm%40<26 then pr("pressione c",40,102,10) end
end

-- arvores e fonte grandes (16x16), colisao continua 1 tile
function dtr(cx,cy,a)
 for ty=max(cy\8,0),min(cy\8+16,79) do
  for tx=max(cx\8-1,0),min(cx\8+16,79) do
   local i=tx+ty*80
   local t,v=T[i],V[i]
   local g=t==1 and LT[i]==1
   if v==3 and t==5 or v==36 and t==8 or v==35 and t==1 or g then
    if (v==36 or ty*8+4<py)==(a or false) then
     local x,y=tx*8,ty*8
     if g then sig(x,y,tx,ty)
     elseif v==35 then
      -- poste: cabeca + haste curta + base (recortes do sprite 46, 11px)
      sspr(112,16,8,4,x,y-3)
      sspr(112,20,8,5,x,y+1)
      sspr(112,30,8,2,x,y+6)
     else spr(v==36 and 44 or (tx+ty)%3==0 and 42 or 40,x-4,y-(v==36 and 4 or 8),2,2) end
    end
   end
  end
 end
end

-- semaforo (11px): cabeca 4x8 + haste. fica dentro do tile da calcada
-- ciclo 720 quadros: verde 300, amarelo 60, vermelho 360. postes vizinhos (tx par/impar) ficam opostos
function sig(x,y,tx,ty)
 local s=(tm+tx%2*360+ty\15*140+tx\50*180)%720
 local k=s<300 and 2 or s<360 and 1 or 0
 rectfill(x+3,y+5,x+4,y+7,5)
 rectfill(x+2,y-3,x+5,y+4,0)
 x+=1-tt(tx+1,ty)
 for i=0,2 do
  rectfill(x+3,y-2+i*2,x+4,y-1+i*2,i==k and (i<1 and 8 or 9+i) or 5)
 end
end

function dz(b)
 for p in all(P) do
  if (p.y<py)==b then dchar(24,p.f,p.x,p.y,p.fl,true) end
 end
end

function _draw()
 local dn=cos(tm/9000)
 lv=dn<-.5 and 2 or dn<0 and 1 or 0
 if ins then door() return end
 cls()
 local cx,cy=px-64,py-64
 if gs==0 then
  cx+=cos(tm/500)*40
  cy+=sin(tm/700)*20
 end
 ccx,ccy=ccx or cx,ccy or cy
 ccx+=(cx-ccx)*.3 ccy+=(cy-ccy)*.3
 cx,cy=ccx\1,ccy\1
 camera(cx,cy)
 dark(lv)
 for ty=cy\8,cy\8+16 do
  for tx=cx\8,cx\8+16 do
   dtile(tx,ty)
  end
 end
 for p in all(pn) do
  local n=p.n
  rectfill(p.l,p.y-16,p.r,p.y-9,bgc[p.k])
  print(n,(p.l+p.r)\2-#n*2+1,p.y-14,tcc[p.k])
 end
 if lv>0 then
  for l in all(LP) do
   if dist(l[1],l[2],px,py)<110 then glow(l[1],l[2]) end
  end
 end
 for s in all(S) do
  pl(8,3) spr(9,s.x-4,s.y-4) pl(8,8)
 end
 for p in all(phones) do
  pl(8,gc[p.g+1]) spr(15,p.x-4,p.y-4) pl(8,8)
  if tm%30<15 then circ(p.x,p.y,8,gc[p.g+1]) end
 end
 dtr(cx,cy,true)
 for c in all(C) do dcar(c) end
 dz(true)
 if not drv and gs>0 and (inv<=0 or tm%4<2) then
  dchar(vs>0 and 74 or 16,face,px,py,0,mov)
  local m,w=px+fw*2,fh>0 and "" or ({"444","5666","4999","447","45666","33b","466","455666"})[wp]
  for i=1,#w do
   local k=i+1+sw/2
   pset(m+fu*k,py+fw*k,ord(w,i)-48)
  end
 end
 dz(false)
 dtr(cx,cy)
 for q in all(Q) do pset(q.x,q.y,q.c) end
 for b in all(B) do circfill(b.x,b.y,b.t\3,b.t==3 and 9 or 7) end
 for f in all(F) do
  circfill(f.x,f.y,7+rnd(2),8)
  circfill(f.x,f.y-1,4+rnd(2),9)
  circfill(f.x,f.y-2,2,10)
 end
 if lv>0 and drv then
  glow(drv.x+cos(drv.a)*14,drv.y+sin(drv.a)*14)
  circfill(drv.x+cos(drv.a)*8,drv.y+sin(drv.a)*8,1,10)
 end
 camera()
 pal()
 if gs==0 then title() else hud() end
end

function tt(x,y)
 return x>=0 and y>=0 and x<80 and y<80 and T[x+y*80] or 3
end

function sol(x,y)
 local t,i=tt(x\8,y\8),x\8+y\8*80
 return V[i]==35 or LT[i]==1 or t==2 or t==3 or t==5 or t==6 or t>7
end

-- eixo: a=tipo (0/1 rua,2 calcada,3 miolo) u=posicao no quarteirao b=numero
function ln(s)
 local a,u,b,n,k={},{},{},0,0
 for i=0,79 do a[i]=3 end
 for v in all(s) do
  a[v],a[v+1],a[v+2]=0,1,2
  if v>0 then a[v-1]=2 end
 end
 for i=0,79 do
  if a[i]==0 then k+=1 end
  b[i]=k
  if a[i]==3 then u[i]=n n+=1 else n=0 end
 end
 return a,u,b
end

-- tipos: 0 rua 1 calcada 2 predio 3 muro 4 grama 5 arvore 6 agua 7 ponte 8 cerca/fonte 9 tumulo
function gen()
 T,V,LP,LT={},{},{},{}
 ax,ux,bx=ln(vx)
 ay,uy,by=ln(hy)
 for y=0,79 do
  for x=0,79 do
   local a,b,t,v=ax[x],ay[y],4,0
   local u,w=ux[x],uy[y]
   local h=(x*7+y*13+x*y)%10
   if a==3 and bx[x]==4 and abs(x-52-sin(y/60)*3)<2.5 then
    t,v=b>2 and 6 or 7,b>2 and 30 or 12
   elseif a<2 or b<2 then
    t,v=0,12
    if a>1 and x%2==0 and ax[x-1]!=2 then v=b==0 and 13 or 14
    elseif b>1 and y%2==0 and ay[y-1]!=2 then v=a==0 and 22 or 23 end
   elseif a==2 or b==2 then
    t,v=1,11
    if (x*3+y*5+4)%11==0 then
     v=35
     add(LP,{x*8+4,y*8-1})
    end
   else
    local z=sub(zn[by[y]],bx[x],bx[x])
    local e=ax[x-1]==2 or ax[x+1]==2 or ay[y-1]==2 or ay[y+1]==2
    if z=="f" or z=="r" then
     if h<3 and not e then t,v=5,3 elseif h==3 then v=37 end
    elseif z=="p" then
     if u==4 and w==5 then t,v=8,36
     elseif abs(u-4)+abs(w-5)<3 then t,v=1,11
     elseif h<2 and not e then t,v=5,3
     elseif h<4 then v=38 end
    elseif z=="c" then
     if e and not (u==4 and w==0) then t,v=8,34
     elseif u%2==1 and w%3==1 then t,v=9,33 end
    elseif z=="h" then
     if (u-1)%4<3 and (w-1)%5<3 then
      t,v=2,(4+(bx[x]+by[y]+(u+3)\4+(w+4)\5)%3)*256+1
     elseif h<2 and not e then t,v=5,3
     elseif h==2 then v=38 end
    elseif z=="T" then
     local c=ord(ssp,(bx[x]+by[y]*8)*9+u\6+w\6*3+1)-48
     if e and not(c==5 and u<1 and ay[y-1]!=2 and ay[y+1]!=2) or u%6==5 or w%6==5 then t,v=1,11
     else
      t,v=2,(c>0 and c+6 or gng(x*8)+1)*256+(c>0 and 3 or 1+(bx[x]*5+by[y]*3+u\6+w\6*2)%3)
     end
    elseif e then t,v=1,11
    elseif w<9 then t,v=2,7*256+2
    elseif u%3==1 and w==9 then t,v=8,39
    else t,v=1,11 end
   end
   local i=x+y*80
   T[i],V[i],LT[i]=t,v,b==2 and a<2 and 6 or a==2 and b<2 and 5
  end
 end
 -- fachadas: altura do predio vem de v%256, contada de baixo pra cima
 for x=0,79 do
  local n=0
  for y=79,0,-1 do
   local i=x+y*80
   if T[i]==2 then
    n+=1
    local g,f=V[i]\256,V[i]%256
    V[i]=g*256+(n>f and (n==f+1 and 8 or 7) or n==1 and (x%4==1 and 6 or x%2==0 and 5 or 4) or (x+y)%2==0 and 5 or 4)
   else n=0 end
  end
 end
 dr,pn,lk={},{},{}
 local q={}
 for y=0,79 do
  for x=0,79 do
   local i=x+y*80
   if T[i]==2 and V[i]%256==6 then
    local kk=(bx[x]+by[y]*8)*9+ux[x]\6+uy[y]\6*3+1
    local c=ord(ssp,kk)-48
    dr[i]=c>0 and not sol(x*8,y*8+8) and c or 1
    if dr[i]>1 and not q[kk] then
     q[kk]=1
     local l,r,m=x,x,c==6 and 2 or 4
     while T[l-1+y*80]==2 and x-l<m do l-=1 end
     while T[r+1+y*80]==2 and r-x<m do r+=1 end
     local n
     for j=c*3-5,c*3-3 do
      n=lb[j]
      if #n*4-1<=(r-l+1)*8 then break end
     end
     add(pn,{x=x*8,y=y*8,k=c,l=l*8,r=r*8+7,n=n})
    end
    if dr[i]<2 and rnd()<.45 then lk[i]=1 end
   end
  end
 end
 local o=split("28,10,1,31,13,1,58,10,1,61,13,1,43,40,1,46,43,1,30,29,2,60,29,2,14,44,2,14,59,2,45,59,2,30,75,2,30,15,3,33,11,4,60,15,3,63,11,4,45,45,3,48,41,4")
 for i=1,#o,3 do LT[o[i]+o[i+1]*80]=o[i+2] end
end

function gng(x)
 return min(x\214,2)
end

function dist(a,b,c,d)
 local x,y=(a-c)/64,(b-d)/64
 return sqrt(x*x+y*y)*64
end

function pr(s,x,y,c,o)
 for i=-1,1 do
  for j=-1,1 do print(s,x+i,y+j,o or 0) end
 end
 print(s,x,y,c)
end

-- papel com sombra e fita
function pap(x,y,w,h)
 rectfill(x+2,y+2,x+w+2,y+h+2,0)
 rectfill(x,y,x+w,y+h,7)
 rect(x,y,x+w,y+h,6)
 rectfill(x+w\2-4,y-2,x+w\2+3,y+1,10)
end

-- mensagem curta escrita a caneta no bilhete
function note(s,y)
 local w=#s*4+8
 pap(64-w\2,y,w,12)
 print(s,68-w\2,y+4,1)
end

function dark(l)
 for c=0,15 do
  pal(c,l>0 and dk[l][c+1] or c)
 end
end

function glow(x,y)
 spr(142,x-8,y-8,2,2)
end

function fx(x,y,c,n)
 for i=1,n do
  local a=rnd()
  add(Q,{x=x,y=y,dx=cos(a)*rnd(1.5),dy=sin(a)*rnd(1.5),l=8+rnd(8),c=c})
 end
end

function spl(x,y)
 add(S,{x=x,y=y})
 if #S>40 then deli(S,1) end
end

function rpos(t,a,b)
 for i=1,12 do
  local n,r=rnd(),a+rnd(b-a)
  local x,y=px+cos(n)*r,py+sin(n)*r
  if tt(x\8,y\8)==t then return x,y end
 end
end

function blk(x,y,a)
 local f,s,n=cos(a),sin(a),0
 for i=-1,1,2 do
  for j=-1,1,2 do
   if sol(x+f*7*i-s*3*j,y+s*7*i+f*3*j) then n+=1 end
  end
 end
 return n
end

function mv(c)
 local a=c.a
 local b0=blk(c.x,c.y,a)
 local nx,ny=c.x+cos(a)*c.v,c.y+sin(a)*c.v
 -- so anda se nao entrar mais fundo
 local function ok(x,y)
  local b=blk(x,y,a)
  return b==0 or b0>0 and b<=b0 and not sol(x,y)
 end
 if ok(nx,ny) then
  c.x,c.y=nx,ny
 elseif ok(nx,c.y) then
  c.x=nx
  c.v*=.85
 elseif ok(c.x,ny) then
  c.y=ny
  c.v*=.85
 else
  c.dmg=abs(c.v)
  c.v*=-.3
  c.hit=true
 end
 if not sol(c.x,c.y) then c.gx,c.gy=c.x,c.y
 elseif c.gx then c.x,c.y=c.gx,c.gy end
end

-- desce do carro
function out()
 local c=drv
 c.v,c.t=0,3
 px,py=c.x,c.y
 for k in all(split("8,-8,14,-14")) do
  local x,y=c.x-sin(c.a)*k,c.y+cos(c.a)*k
  if bc(x,y)<1 then px,py=x,y break end
 end
 drv=nil
end

-- carro mais proximo (ate r px)
function ncar(r,w)
 local b
 for c in all(C) do
  local d=dq(c)
  if d<r and not(w and c.w) then b,r=c,d end
 end
 return b
end

function act()
 if drv then
  out()
  return
 end
 for p in all(phones) do
  if dq(p)<10 then
   sav()
   if dia<1 then dia,dl,di,tm=1,{{"exercito: central de","resgate. quem fala?","voce: sobrevivente. a","cidade esta tomada!"},
{"exercito: onde voce esta?","voce: em pedra negra. fica","longe de tudo.","exercito: o resgate leva","7 dias. aguente firme."},
{"exercito: se esconda de","noite e fique vivo.","voce: vou aguentar.","exercito: boa sorte."}},1,0
   else sm("jogo salvo",50) end
   return
  end
 end
 for i=-1,1 do
  for j=-1,1 do
   local tx,ty=px\8+i,py\8+j
   local n=tx+ty*80
   if dr[n] and dist(px,py,tx*8+4,ty*8+4)<12 then
    if lk[n] then sm("casa trancada",50) else ins,mt,mn=n,0,1 sh=dr[n]==4 and fd or dr[n]==6 and of or ar end
    return
   end
  end
 end
 local b=ncar(14)
 if b then
  if b.w or b.l then sm(b.w and "carro destruido" or "carro trancado",50)
  else
   if b.t!=3 then hot(3) end
   drv,b.t,b.v=b,4,0
  end
 end
end

-- t = paginas; cada pagina = lista de linhas ja quebradas (max 26 colunas)
function die(m)
 for i=0,8 do dset(i,0) end
 dl,di={{"voce morreu!",m}},1
end

function mq(o)
 return o.x/8-msx-12,o.y/8-msy-12
end

function mp(o,c)
 local i,j=mq(o)
 if i*i+j*j<140 then pset(107+i,104+j,c) end
end

function sav()
 dset(0,mon) dset(1,bat) dset(4,1) dset(2,dia) for i=5,8 do dset(i,am[i]) end
end

-- lugares: nome,kit,sup,perigo,piso,mobilia
ssp="00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020004000030000000000000000000040000000000000000000000000000000000000000050000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000006000000030050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
bgc=split("0,7,3,9,1,5")
tcc=split("0,8,7,1,10,7")
cm=split("0,8,10,11,12,9")
lb=split("hospital,hosp,h,escola,esc,e,mercado,merc,m,delegacia,deleg,dp,garagem,gar,g")
lc=split("casa,.3,40,0,4,2,hospital,1,0,0,7,8,escola,.3,90,.4,5,3,mercado,.6,75,.1,6,9,delegacia,.2,110,.2,1,12,garagem,0,70,.2,13,10")

-- dentro: esconde e espera a noite passar (sem curar)
function insd()
 local k=dr[ins]
 heat=max(0,heat-.3)
 if k>3 then
  if btnp(2) then mn=(mn-2)%#sh+1 end
  if btnp(3) then mn=mn%#sh+1 end
  if btnp(4) then buy() end
 else
  if btnp(4) then srch() end
 end
 if btnp(5) then ins,inv,cd=nil,60,15 end
end

function srch()
 local k=dr[ins]
 local o=k*6
 if k==3 then return end
 mt=60
 if lt[ins] then
  msg="ja vasculhado"
  return
 end
 lt[ins]=1
 if rnd()<lc[o-2] then
  hp=max(1,hp-10)
  sfx(3)
  dm="emboscada: "..lc[o-5]
  msg="zumbi escondido! -10"
 elseif k==2 then
  hp=100
  sfx(7)
  msg="curativo completo!"
 else
  local n=flr(lc[o-3]*(.5+rnd()))
  mon+=n
  msg="+"..n.." $"
  sfx(7)
 end
end

function door()
 local k=dr[ins]
 local o=k*6
 local n=lc[o-5]
 cls(1)
 rectfill(8,16,119,100,lc[o-1])
 rect(8,16,119,100,0)
 if k>2 then
  rectfill(12,20,115,92,split("3,4,1,5")[k-2])
  rect(12,20,115,92,6)
  if k==3 then
   print("mural: mapa da cidade",16,23,10)
   for i=1,#pn do
    local p=pn[i]
    print(lc[p.k*6-5].." "..(dq(p)\2).."m",16,22+i*6,7)
   end
   print("zumbis saem a noite",16,87,8)
  else
   print("$ "..mon.."  fome "..fm\1,16,22,10)
   for i=1,#sh do
    local w=sh[i]
    print((i==mn and ">" or " ")..w[1].." "..w[2],16,21+i*6,i==mn and 7 or 6)
   end
  end
 else
  for i=0,2 do rectfill(16+i*36,24,40+i*36,40,lc[o]) end
  spr(16,60,64)
 end
 pr(n,64-#n*2,6,10)
 print("vida "..hp\1,2,104,11)
 print(lv>0 and "noite la fora" or "dia la fora",44,104,lv>0 and 12 or 10)
 print(k==3 and "x:sair" or k>3 and "o:comprar  x:sair" or "z:procurar  x:sair",26,112,7)
 print(k>3 and "cima/baixo:escolher" or "",26,120,6)
 if mt>0 then note(msg,82) end
end

-- armas: nome,dano,recarga
wd=split("bastao,1,14,facao,2,11,taco,3,26,estilingue,1,16,espingarda,1,42,granada,2,50,pistola,2,14,ak-47,3,5")

-- loja: nome,preco,funcao (callback: retorna 1 se a compra valeu)
function eat(n)
 if fm<100 then fm=min(100,fm+n) return 1 end
 sm("sem fome",50)
end

-- mercado: comida e coisas
fd={
{"pao",12,eat,20},
{"enlatado",25,eat,45},
{"refeicao",45,eat,80}}

-- oficina: conserto do carro mais proximo
function rp(n)
 local b=ncar(40,1)
 if b and b.h<100 then
  b.h=min(100,b.h+n)
  return 1
 end
 sm(b and "o carro ja esta inteiro" or "deixe um carro perto da porta",60)
end
of={
{"reparo leve",40,rp,40},
{"conserto total",80,rp,100}}

function ga(w)
 if hv(w) then am[w]+=(w-4)*6 return 1 end
 sm("falta a arma",60)
end

function gw(w)
 if not hv(w) then
  bat|=1<<w-1
  return 1
 end
end

-- delegacia: armas
-- precos reais
ar={
{"facao",150,gw,2},
{"taco",200,gw,3},
{"estilingue",100,gw,4},
{"espingarda",300,gw,5},
{"pistola",300,gw,7},
{"ak-47",700,gw,8},
{"granada x3",60,function() am[6]+=3 bat|=32 return 1 end},
{"cartuchos espingarda x6",50,ga,5},
{"balas pistola x18",40,ga,7},
{"balas ak-47 x24",60,ga,8},
{"colete",150,function() vs=100 return 1 end}}

function buy()
 local w=sh[mn]
 mt=0
 if mon>=w[2] and w[3](w[4]) then
  mon-=w[2]
  sfx(7)
  sav()
  sm("pronto!",60)
 else
  sfx(6)
  if mt<1 then sm(mon<w[2] and "falta $" or "voce ja tem",60) end
 end
end

function hv(w)
 return (bat&1<<w-1)>0
end

function cw()
 local o=wp
 if fh>0 then fh=0 else
  repeat wp=wp%8+1 until hv(wp)
  fh=wp>o and 0 or 1
 end
 sfx(4)
end

-- tiro: 4 estilingue, 5 espingarda (5 balins), 6 granada
function shoot()
 local n,s,l,t=1,3,40,1
 if wp==5 then n,l,t=5,14,2 elseif wp==6 then s,l,t=2.2,22,3 end
 if wp>4 then am[wp]-=1 end
 for i=1,n do
  local k=(i-n/2-.5)*.4
  add(B,{x=px+fu*5,y=py+fw*5,dx=fu*s+fw*k,dy=fw*s+fu*k,l=l,d=wd[wp*3-1],t=t})
 end
 hot(split("1,8,4,3,2")[wp-3])
 fx(px+fu*6,py+fw*6,10,3)
 sfx(wp==5 and 2 or 0)
end

__gfx__
333333333b33b33b4444444400111100666666666666666666111166888888888888888800000000011111106666666d5555555555555555aaaaaaaa00000800
33b33333b3bb3bb34494444401bbbb10666666666111111661444416222222228888888800880000177777716666666d55155555551555555515555500000800
333333333b33b3b3444444441bb3bbb16666666661cccc1661444416888888882222222208888000177887716666666d55555555555555555555555501111110
33333b33b3bb3bb3444444941bbbb3b16666666661cc7c1661494416888888888888888808888800178888716666666d55555515555555155555551501666610
333333333b3b3b334444444401bbbb106666666661cccc1661444416222222228888888800888000177887716666666d55555555555555555555555501611610
b3333333b3b3bb3b4944444400144100666666666111111661444416888888882222222200088000177777716666666d51555555515555555155555501666610
3333333333b33b334444444400144100666666666666666661444416888888881111111100000000011111106666666d55555555555555555555555501111110
33333b33b3b3b3b3444449440011110066666666666666661144441122222222000000000000000000000000dddddddd55555155aaaaaaaa5555515500000000
0000000000000000000000000000000000000000000000005555555aa5555555000000000000000000000000000000000000000000000000cccccccccccccccc
0000000000000000000000000000000000000000000000005515555aa5155555000000000000000000000000000000000000000000000000cc7cc1ccc7cccc1c
0001110000011100000111000001110000011100000111005555555aa5555555000111000001110000011100000111000001110000011100cccccccccccccccc
0014441000144410001444100014441000144410001444105555551aa55555150013331000133310001333100013331000133310001333101cccc7cccc1cc7cc
0001f1000001f100001444100014441000144f1000144f105555555aa55555550008b8000008b800001333100013331000133b8000133b80cccccccccccccccc
00fcccf000fcccf000fcccf000fcccf0001cfc10001cfc105155555aa155555500bdddb000bdddb000bdddb000bdddb0001ddbb0001ddbb0cc1cccccc1cccccc
001ccc10001ccc10001ccc10001ccc10001ccc10001ccc105555555aa5555555001ddd10001ddd10001ddd10001ddd10001ddd10001ddd10cccc7cccccc7cccc
0005050000005500000505000000550000050500000055005555515aa5555155000303000000330000030300000033000003030000003300cccccccccccccccc
0000000000000000d0d0d0d0666aa66d66dddd6600000000000000004444444400011bb3b3b11000000000133100000000000000000000000011110011111111
0000000000066000d0d0d0d066a77a6d6dccccd6000bb00000800000499999940013b3bb3b3b31000000001b31000000000001111110000001aaaa1017788771
0000000000677600dddddddd666aa66ddcc77ccd00b3bb00000000004949949401bb3b3bb3b3b310000001b3331000000001166cc661100001a77a1017788771
0000000000677600d0d0d0d06665566ddc7cc7cd0bb3bbb000000a0049999994013bb3b3b3333b1000001b3333310000001666c77c6661000011110018888881
0000000000666500d0d0d0d06665566ddcc77ccd0bbbb3b0000000004999999413b3bb3b3b3333310001b3b333331000016667c77cc666100005600018888881
0000000000666500dddddddd6665566ddccccccd00bbbb000e000000494994941b3b3b3333b333310000113b331100001666ccc77ccc66610005600017788771
0000000000555500d0d0d0d06655556d6dccccd60000000000000000499999941bb3b3b333333311000013b333310000166c7cc77cc7c6610005600017788771
0000000000000000d0d0d0d0dddddddd66dddd6600000000000008004444444413b3333b3333133100013b333333100066ccccc77ccccc660005600011111111
4444444401111110111111110011110000000000000000000000000000000000133b3333333131310013b3b33333310066c7ccc77c7ccc660005600000000000
433773341aa44aa11cc11cc101666610000000000000000000000000000000000133b33331331310000111333311100066cccc7cccccc7660005600000000000
437337341a4aaaa11c1aa1c1166116610000000000000000000000000000000000133333131331000001b3b333331000166cccccc7ccc6610005600000000000
437337341aa44aa111aaaa1116100161000000000000000000000000000000000001331331311000011b3b33333331101666c7cccccc66610005600000000000
437777341aaaa4a11caaaac11610016100000000000000000000000000000000000011144111000013b3b3144133333101666ccc7cc666100005600000000000
437337341aa44aa11c1aa1c116611661000000000000000000000000000000000000001441000000011111144111111000166666666661000005600000000000
437337341aaaaaa11c1cc1c101666610000000000000000000000000000000000000001441000000000000144100000000011666666110000055550000000000
44444444011111100111111000111100000000000000000000000000000000000000000110000000000000011000000000000111111000000155551000000000
11101110011111100111110011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18111810117777101177711017100000000000000100000000000001100000000000001111000000000000000000000000000000000000000000000000000000
18811810171111101700071017100000000000001a1000000000001aa1110000000001aeea100000000111000001110000011100000111000001110000011100
1818181011777110170007101710000000000001eaa100000000001eaeea100000001aaeeaa10000001444100014441000144410001444100014441000144410
181188101111171017000710171111100000001e1eee1000000001e1eeaa100000001e11eee100000001f1000001f100001444100014441000144f1000144f10
18111810177771101177711017777710000001e111eaa100000001e1111e100000001e1111e1000000f555f000f555f000f555f000f555f00015f5100015f510
1110111011111100011111001111111000001eee111ea10000001ee1111e100000001e1111e10000001555100015551000155510001555100015551000155510
000000000000000000000000000000000001eeeee111e10000001eeeee1e100000001eeeeee10000000505000000550000050500000055000005050000005500
01eeeeeee11ee1000188eeeee111ea10001eeeeeeeee100000001eeeeee1000000001eeeeee10000000000000000000000000000000000000000000000000000
0018eeeee11ea100001eeeeeeeee11000018eeeeeee100000001eeeeeee1000000001eeeeee10000000000000000000000000000000000000000000000000000
0018eeeeeeeea100001e8eeeee11000000188eeeee1000000001eeeeee10000000001eeeeee10000000000000000000000000000000000000000000000000000
000111111111100000188ee1110000000001e8eee1000000000188eeee10000000001eeeeee10000000000000000000000000000000000000000000000000000
000000000000000000011110000000000000188e1000000000018ee8e10000000000188ee8810000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000001110000000000001118810000000000018111100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001100000000000001000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011a1000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011100000000001eaae100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011eaa1000000001e11eea10
000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111110000000111e11eae10000001ee111eaa1
0000000000000000000000000000000000000000000000000000000000000000000000000000000018eeeeeeeee1eea1000011eeee11eee1000001eeee11ee10
0000000000000000000000000000000000000000000000000000000000000000000000000000000088eeeeeeeee11eaa0111eeeeeee11eae00001eeeeee11e10
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeee11eee1eeeeeeeeee11eaa0001eeeeeeeee100
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeee11ee188eeeeeeeeee1ee1001eeeeeeeee1000
0000000000000000000000000000000000000000000000000000000000000000000000000000000018eeeeeeeee11ea118eeeeeeeeee111001eeeeeeeee10000
0000000000000000000000000000000000000000000000000000000000000000000000000000000018eeeeeeeeeeeea11eeeeeeeee110000018eeeeeee100000
0000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111101e8eeee111000000188eeeeee1000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000188e1100000000001eeeeee10000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000000000000188e1100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001810000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ae110000000001aeea100000000000a0a0a00000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000001eaaee100000001aaeeaa1000000000a0a0a0a0000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeaa10000001eeeeee100000000a0a0a0a0a000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111eea10000001e1111e10000000a0a0a0a0a0a00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001ee1111e1000000111111e1000000a0a0a0a0a0a0a0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeee11100000001eeeeee100000a0a0a0a0a0a0a0a
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeeee100000001eeeeee10000a0a0a0a0a0a0a0a0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeee1000000001eeeeee100000a0a0a0a0a0a0a0a
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeee1000000001eeeeee10000a0a0a0a0a0a0a0a0
000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeeee1000000001eeeeee100000a0a0a0a0a0a0a0a
000000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeee10000000001eeeeee10000a0a0a0a0a0a0a0a0
00000000000000000000000000000000000000000000000000000000000000000000000000000000001eeeeeee10000000001eeeeee100000a0a0a0a0a0a0a0a
000000000000000000000000000000000000000000000000000000000000000000000000000000000018eeeee100000000001eeeeee1000000a0a0a0a0a0a0a0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000188eeee100000000001eeeeee10000000a0a0a0a0a0a00
000000000000000000000000000000000000000000000000000000000000000000000000000000000001ee88e10000000000188ee88100000000a0a0a0a0a000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000111810000000000001811110000000000a0a0a0a0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777777777777777666666666666666600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000777777777111111771111117666666666666666600000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007777777771cccc171cc11cc1666556666666666600000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007777777771c77c171c7117c1666556667777777700000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007777777771cccc171cc11cc1666666668888888800000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000077777777711111171cc11cc1666666668888888800000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777777771cc11cc1666666662222222200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666611111111666666661111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaa888888888888888800000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa444444aa444444a888888888888888800000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa4cccc4a44944944222222222222222200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa4c77c4a44944944888888889999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa4cccc4a44944944888888884444444400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa4cccc4a44944944222222224444444400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa444444a44944944888888889999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000999999999999999911111111888888881111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffbbbbbbbbbbbbbbbb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff111111ff111111fbbbbbbbbbbbbbbbb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff1c7cc1f1cc77cc13bbb3bbbbbbbbbbb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff1cc7c1f1cc88cc1bbbbbbbbbbbbbbbb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff1cccc1f1cccccc1bbbbbbbb7777777700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff1cccc1f1cccccc13bbb3bbb3333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff111111f1cccccc1bbbbbbbb3333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000999999999999999911111111bbbbbbbb1111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddd111111111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddd111111dd555555d151115111111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddd1c1c1cd5566665511111111cccccccc00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddd1c1c1cd55611655115111517777777700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddd1c1c1cd5566665511111111cccccccc00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddd111111d5566665515111511dddddddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddd5566665511111111dddddddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555511111111111111115555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666666555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000666666666111111611111111555555555555555500000000
000000000000000000000000000000000000000000000000000000000000000000000000000000005555555561cccc161666666151555155a1a1a1a100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006666666661c77c1615555551555555551a1a1a1a00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000066666666611111161666666155555555a1a1a1a100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555556666666615555551551555155555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666616666661555555551111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555511111111555555550000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00030000246401e630186200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000146500e6500a6400663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000c6700a660086500664004630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001e3501a350163401233000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000240502b050300500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000024350283502b350303502b340303500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001e25018250122500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000280502c050300503405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003000080c0200f0200c0300a0200c020110200f0300a020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 08404040
