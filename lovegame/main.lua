local CASES = require("case_data")
local W, H = 1280, 720
local screen, caseOrder, casePos = "title", {}, 1
local stagePos, score, answered, selected = 1, 0, false, 1
local feedback, feedbackGood, caseCorrect = "", false, 0
local current, fonts, art, photos = nil, {}, {}, {}
local scale, ox, oy = 1, 0, 0
local colors = {
  ink={.055,.075,.13}, navy={.075,.12,.24}, blue={.12,.35,.82}, cyan={.17,.79,.9},
  red={.91,.19,.22}, gold={1,.76,.19}, cream={1,.96,.82}, paper={1,.995,.94},
  white={1,1,1}, muted={.68,.75,.88}, green={.24,.76,.48}, dark={.04,.05,.09}
}
local function set(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function rounded(x,y,w,h,r,c)
  set(c); love.graphics.rectangle("fill",x,y,w,h,r or 8)
end
local function text(s,x,y,font,c,align,limit)
  love.graphics.setFont(font); set(c or colors.ink)
  love.graphics.printf(s,x,y,limit or 1000,align or "left")
end
local function center(s,y,font,c)
  love.graphics.setFont(font); set(c or colors.ink)
  love.graphics.printf(s,0,y,W,"center")
end
local function imageFit(img,x,y,w,h,alpha)
  if not img then return end
  local iw,ih=img:getDimensions(); local sc=math.min(w/iw,h/ih)
  set(colors.white,alpha or 1); love.graphics.draw(img,x+(w-iw*sc)/2,y+(h-ih*sc),0,sc,sc)
end
local function loadArt()
  local names={"counsel-neutral","counsel-shout","counsel-surprised","prosecutor-neutral","prosecutor-angry","prosecutor-surprised","witness-one","witness-one-doubt","witness-one-shocked","witness-two","witness-two-worry","witness-two-angry"}
  for _,n in ipairs(names) do local ok,v=pcall(love.graphics.newImage,"assets/characters/"..n..".png"); if ok then art[n]=v; v:setFilter("linear","linear") end end
  for _,n in ipairs({"courthouse","courtroom","police-car"}) do local ok,v=pcall(love.graphics.newImage,"assets/"..n..".jpg"); if ok then photos[n]=v; v:setFilter("linear","linear") end end
end
local function loadFonts()
  fonts.tiny=love.graphics.newFont(13); fonts.small=love.graphics.newFont(17); fonts.body=love.graphics.newFont(20)
  fonts.mid=love.graphics.newFont(26); fonts.head=love.graphics.newFont(38); fonts.big=love.graphics.newFont(62); fonts.huge=love.graphics.newFont(84)
end
local function shuffle()
  caseOrder={}; for i=1,#CASES do caseOrder[i]=i end
  for i=#caseOrder,2,-1 do local j=love.math.random(i); caseOrder[i],caseOrder[j]=caseOrder[j],caseOrder[i] end
end
local function beginGame()
  shuffle(); casePos=1; stagePos=1; score=0; caseCorrect=0; screen="intro"; current=CASES[caseOrder[casePos]]
end
local function startCase()
  current=CASES[caseOrder[casePos]]; stagePos=1; caseCorrect=0; answered=false; selected=1; screen="play"
end
local function nextCase()
  casePos=casePos+1
  if casePos>#caseOrder then
    screen="results"
  else current=CASES[caseOrder[casePos]]; stagePos=1; caseCorrect=0; screen="intro" end
end
local function finishAnswer(index)
  if answered then
    if stagePos<#current.stages then stagePos=stagePos+1; answered=false; selected=1; feedback=""; screen="play"
    else screen="ruling" end
    return
  end
  local stage=current.stages[stagePos]; selected=index
  feedbackGood=index==stage.correct
  if feedbackGood then score=score+1; caseCorrect=caseCorrect+1 end
  feedback=stage.choices[index].why; answered=true
end
local function nextAfterRuling() nextCase() end
local function drawBackdrop(kind)
  love.graphics.clear(.035,.055,.11)
  -- dramatic radial rays and halftone texture
  set(colors.navy); love.graphics.rectangle("fill",0,0,W,H)
  for i=1,22 do
    local x=(i*113)%W
    set(i%2==0 and colors.blue or colors.cyan,.045)
    love.graphics.polygon("fill",640,315,x-28,0,x+80,0)
  end
  set(colors.white,.055)
  for y=12,350,18 do for x=(y%36),W,18 do love.graphics.circle("fill",x,y,1.4) end end
  if kind=="court" and photos.courtroom then
    set(colors.white,.16); love.graphics.draw(photos.courtroom,0,0,0,W/photos.courtroom:getWidth(),H/photos.courtroom:getHeight())
    set(colors.navy,.72); love.graphics.rectangle("fill",0,0,W,H)
  elseif kind=="intro" and photos.courthouse then
    set(colors.white,.23); love.graphics.draw(photos.courthouse,0,0,0,W/photos.courthouse:getWidth(),H/photos.courthouse:getHeight())
    set(colors.navy,.69); love.graphics.rectangle("fill",0,0,W,H)
  end
end
local function drawTop(label)
  rounded(28,20,262,42,8,colors.red)
  local labelFont=#label>24 and fonts.tiny or fonts.small
  text(label,42,31,labelFont,colors.white,"left",234)
  text("FOURTH COUNSEL",W-294,29,fonts.small,colors.gold,"right",260)
  love.graphics.setLineWidth(2); set(colors.white,.22); love.graphics.line(28,73,W-28,73)
end
local function drawCharacter(name,x,y,w,h,alpha)
  imageFit(art[name],x,y,w,h,alpha)
end
local function drawLogo(y)
  center("FOURTH",y,fonts.huge,colors.cream)
  center("COUNSEL",y+80,fonts.big,colors.gold)
  love.graphics.setLineWidth(6); set(colors.red); love.graphics.line(392,y+151,888,y+151)
  center("THE PEOPLE v. YOUR JUDGMENT",y+164,fonts.small,colors.white)
end
local function drawTitle()
  drawBackdrop("intro")
  drawCharacter("counsel-neutral",42,94,440,610,.94)
  drawCharacter("prosecutor-neutral",804,90,430,615,.92)
  -- impact starburst
  set(colors.red); love.graphics.polygon("fill",640,140,666,235,750,206,704,278,782,325,685,330,690,425,635,365,575,426,590,331,495,326,573,277,530,204,615,236)
  set(colors.gold); love.graphics.circle("fill",640,300,68)
  text("§",602,244,fonts.huge,colors.navy)
  drawLogo(112)
  rounded(386,486,508,64,13,colors.red); text("START YOUR FIRST CASE",386,502,fonts.mid,colors.white,"center",508)
  center("8 surprise cases  •  3 courtroom calls each  •  24 points possible",580,fonts.small,colors.cream)
  center("Click / Enter to continue     ·     1–3 choose answers     ·     Esc returns to title",614,fonts.tiny,colors.muted)
end
local function drawIntro()
  drawBackdrop("intro"); drawTop("CASE FILE  /  "..casePos.." OF "..#caseOrder)
  drawCharacter("witness-one",24,108,330,492,.91)
  rounded(298,114,930,498,18,colors.paper)
  rounded(298,114,930,52,18,colors.red); love.graphics.rectangle("fill",298,140,930,26); text(current.tag,322,129,fonts.small,colors.white)
  text(current.title,332,187,fonts.head,colors.ink,"left",850)
  text(current.setting,334,235,fonts.small,colors.blue,"left",840)
  text("THE FACTS",334,278,fonts.small,colors.red)
  text(current.facts,334,305,fonts.body,colors.ink,"left",844)
  rounded(332,422,846,1,1,{.83,.84,.82})
  text("EVIDENCE AT ISSUE",334,440,fonts.small,colors.red)
  text(current.item,334,464,fonts.mid,colors.ink,"left",820)
  text("Doctrine: "..current.doctrine,334,520,fonts.small,colors.blue,"left",825)
  rounded(516,634,248,52,10,colors.gold); text("ENTER COURT  →",516,646,fonts.small,colors.navy,"center",248)
  text("Click anywhere / Enter",18,674,fonts.tiny,colors.muted)
end
local function answerRect(i) return 100, 458+(i-1)*59, 1080, 50 end
local function drawCourt()
  drawBackdrop("court"); drawTop("TRIAL  "..casePos.." / "..#caseOrder.."     •     QUESTION "..stagePos.." / 3")
  -- courtroom bar and two opponents
  set(colors.gold); love.graphics.rectangle("fill",0,346,W,6)
  set(colors.ink); love.graphics.rectangle("fill",0,352,W,114)
  set(colors.gold,.75); love.graphics.rectangle("fill",0,460,W,7)
  drawCharacter(answered and (feedbackGood and "counsel-shout" or "counsel-surprised") or "counsel-neutral",18,116,410,462,.98)
  drawCharacter(answered and (feedbackGood and "prosecutor-surprised" or "prosecutor-angry") or "prosecutor-neutral",810,110,430,470,.98)
  local witness=current.witness or "witness-one"
  drawCharacter(witness,473,144,320,330,.82)
  rounded(34,82,366,44,8,colors.blue); text("DEFENSE  /  ATTORNEY",52,93,fonts.small,colors.white)
  rounded(880,82,366,44,8,colors.red); text("PROSECUTION  /  OPPOSING COUNSEL",896,93,fonts.tiny,colors.white)
  rounded(72,365,1135,343,17,colors.paper)
  rounded(72,365,1135,52,16,colors.navy); love.graphics.rectangle("fill",72,398,1135,19)
  local stage=current.stages[stagePos]
  text("THE COURT WANTS YOUR THEORY",98,399,fonts.small,colors.gold)
  text(stage.prompt,100,422,fonts.body,colors.ink,"left",1070)
  for i,ch in ipairs(stage.choices) do
    local x,y,w,h=answerRect(i); local c=colors.white
    if answered and i==stage.correct then c={.77,.97,.83} elseif answered and i==selected then c={1,.80,.77} elseif not answered and i==selected then c={.83,.91,1} end
    rounded(x,y,w,h,9,c)
    set(not answered and i==selected and colors.blue or colors.ink)
    love.graphics.setLineWidth(not answered and i==selected and 3 or 1); love.graphics.rectangle("line",x,y,w,h,9)
    rounded(x+12,y+9,40,41,8,not answered and i==selected and colors.blue or colors.navy)
    text(tostring(i),x+12,y+17,fonts.small,colors.white,"center",40)
    text(ch.text,x+64,y+11,fonts.small,colors.ink,"left",w-79)
  end
  if answered then
    rounded(108,636,1065,61,9,feedbackGood and colors.green or colors.red)
    local label=(feedbackGood and "OBJECTION SUSTAINED!  " or "OBJECTION OVERRULED.  ")..feedback
    text(label,126,645,fonts.tiny,colors.white,"left",1030)
    rounded(1080,17,166,43,8,colors.gold); text(stagePos==3 and "SEE RULING →" or "CONTINUE →",1080,28,fonts.tiny,colors.navy,"center",166)
  else
    text("Choose a response",101,667,fonts.tiny,colors.muted)
  end
end
local function drawRuling()
  drawBackdrop("court"); drawTop("THE COURT HAS RULED")
  drawCharacter(caseCorrect==3 and "counsel-shout" or "counsel-surprised",8,104,455,590,.94)
  local good=caseCorrect==3
  rounded(350,132,858,496,18,colors.paper)
  rounded(350,132,858,78,14,good and colors.green or colors.red)
  love.graphics.rectangle("fill",350,180,858,30)
  text(good and "PERFECT ARGUMENT!" or "CASE DECIDED",384,147,fonts.head,colors.white)
  text(current.title,390,231,fonts.mid,colors.ink,"left",770)
  text("YOUR PERFORMANCE",390,280,fonts.small,colors.blue)
  for i=1,3 do
    local x=392+(i-1)*71; rounded(x,319,54,14,7,i<=caseCorrect and colors.gold or {.79,.81,.81})
  end
  text(caseCorrect.." / 3 sound calls",390,344,fonts.small,colors.ink)
  rounded(386,391,782,1,1,{.82,.83,.81})
  text("THE RULING",390,413,fonts.small,colors.red)
  text(current.outcome,390,445,fonts.mid,colors.ink,"left",740)
  text("RULE: "..current.doctrine,390,550,fonts.tiny,colors.blue,"left",740)
  rounded(657,648,250,48,9,colors.gold); text(casePos==#caseOrder and "FINAL SCORE →" or "NEXT CASE →",657,660,fonts.small,colors.navy,"center",250)
end
local function drawResults()
  drawBackdrop("intro"); drawCharacter("counsel-shout",28,100,442,594,.92); drawCharacter("prosecutor-surprised",810,91,420,600,.9)
  rounded(322,105,636,502,20,colors.paper)
  rounded(322,105,636,92,18,colors.red); love.graphics.rectangle("fill",322,167,636,30)
  text("TRIAL COMPLETE",352,123,fonts.head,colors.white,"center",576)
  text("YOUR FINAL SCORE",352,229,fonts.small,colors.blue,"center",576)
  text(score.."  /  24",352,272,fonts.huge,colors.ink,"center",576)
  local rank=score>=21 and "ACE COUNSEL" or (score>=15 and "SHARP ADVOCATE" or (score>=8 and "COUNSEL IN TRAINING" or "BACK TO THE BOOKS"))
  text(rank,352,380,fonts.head,colors.red,"center",576)
  text("Every case can turn on one small fact. Review the doctrine,\nquestion the search, and keep the remedy precise.",384,442,fonts.small,colors.ink,"center",512)
  text("EACH CASE IS WORTH 3 POINTS",352,501,fonts.tiny,colors.blue,"center",576)
  rounded(482,536,316,53,10,colors.gold); text("PLAY ANOTHER DOCKET",482,551,fonts.small,colors.navy,"center",316)
  center("Enter to play again     ·     Esc for title",624,fonts.tiny,colors.cream)
end
local function draw()
  love.graphics.push(); love.graphics.translate(ox,oy); love.graphics.scale(scale)
  if screen=="title" then drawTitle() elseif screen=="intro" then drawIntro() elseif screen=="play" then drawCourt() elseif screen=="ruling" then drawRuling() else drawResults() end
  love.graphics.pop()
end
local function advance()
  if screen=="title" then beginGame() elseif screen=="intro" then startCase() elseif screen=="play" then finishAnswer(selected) elseif screen=="ruling" then nextAfterRuling() elseif screen=="results" then beginGame() end
end
function love.load()
  love.graphics.setDefaultFilter("linear","linear",1); love.math.setRandomSeed(os.time()); loadFonts(); loadArt()
  local w,h=love.graphics.getDimensions(); love.resize(w,h)
end
function love.resize(w,h)
  scale=math.min(w/W,h/H); ox=(w-W*scale)/2; oy=(h-H*scale)/2
end
function love.update(dt) end
function love.draw() draw() end
function love.keypressed(key)
  if key=="escape" then screen="title"; return end
  if screen=="title" or screen=="intro" or screen=="ruling" then
    if key=="return" or key=="space" or key=="right" then advance() end
  elseif screen=="play" then
    if not answered then
      if key=="1" or key=="kp1" then selected=1; finishAnswer(1)
      elseif key=="2" or key=="kp2" then selected=2; finishAnswer(2)
      elseif key=="3" or key=="kp3" then selected=3; finishAnswer(3)
      elseif key=="up" then selected=((selected+1)%3)+1
      elseif key=="down" then selected=(selected%3)+1
      elseif key=="return" or key=="space" then finishAnswer(selected) end
    elseif key=="return" or key=="space" or key=="right" then advance() end
  elseif screen=="results" and (key=="return" or key=="space") then
    beginGame()
  end
end
function love.mousepressed(mx,my,button)
  if button~=1 then return end
  local x,y=(mx-ox)/scale,(my-oy)/scale
  if screen=="title" then beginGame()
  elseif screen=="intro" then startCase()
  elseif screen=="ruling" then
    if x>=657 and x<=907 and y>=648 and y<=696 then nextAfterRuling() end
  elseif screen=="results" then
    if x>=482 and x<=798 and y>=536 and y<=589 then beginGame() end
  elseif screen=="play" then
    if answered then
      if x>=1080 and x<=1246 and y>=17 and y<=60 then finishAnswer(selected) end
    else for i=1,3 do local ax,ay,aw,ah=answerRect(i); if x>=ax and x<=ax+aw and y>=ay and y<=ay+ah then finishAnswer(i); return end end end
  end
end
