local CASES = require("case_data")
local W, H = 1280, 720
local DIFFICULTIES = {"FOUNDATIONS", "APPLICATION", "ADVANCED", "EXPERT"}
local TOTAL_QUESTIONS = 0
for _, case in ipairs(CASES) do TOTAL_QUESTIONS = TOTAL_QUESTIONS + #case.questions end
local screen, caseOrder, casePos = "title", {}, 1
local stagePos, score, answered, selected = 1, 0, false, 1
local feedback, feedbackGood, caseCorrect = "", false, 0
local answerHistory = {}
local current, questionDeck, fonts, art, photos = nil, {}, {}, {}, {}
local runMode, difficultyMode, runMaxScore = "campaign", 2, TOTAL_QUESTIONS + #CASES
local hintUsed, hintVisible, crossAnswered, crossCorrect = false, false, false, false
local crossSelected, crossFeedback, evidenceTab, evidenceViewed, notebookIndex = 1, "", 1, {}, 1
local practiceIndex, dailyLabel = 1, ""
local argumentStep, argumentScore, argumentAnswered, argumentChoice = 1, 0, false, 1
local argumentMessage = ""
local animTime = 0
local learnScroll = 0
local scale, ox, oy = 1, 0, 0
local DIFFICULTY_NAMES = {"STUDY", "STANDARD", "EXPERT"}
local EVIDENCE_LABELS = {"CASE FILE", "ITEM AT ISSUE", "PRECEDENT"}
local colors = {
  ink={.10,.12,.15}, navy={.075,.105,.16}, blue={.20,.39,.48}, cyan={.42,.68,.67},
  red={.58,.17,.19}, gold={.84,.68,.42}, cream={.94,.90,.80}, paper={.965,.95,.90},
  white={1,1,1}, muted={.68,.72,.76}, green={.22,.51,.39}, dark={.035,.047,.067}
}
local function set(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function rounded(x,y,w,h,r,c)
  set(c); love.graphics.rectangle("fill",x,y,w,h,r or 8)
end
local function panel(x,y,w,h,r,fill,edge)
  set({.018,.025,.04},.72); love.graphics.rectangle("fill",x+5,y+7,w,h,r or 8)
  rounded(x,y,w,h,r,fill or colors.paper)
  love.graphics.setLineWidth(1.5); set(edge or {.77,.72,.61},.85)
  love.graphics.rectangle("line",x,y,w,h,r or 8)
  set(colors.gold,.72); love.graphics.rectangle("fill",x+18,y+13,35,2,1)
end
local function divider(x,y,w,c)
  set(c or {.77,.74,.68},.9); love.graphics.setLineWidth(1); love.graphics.line(x,y,x+w,y)
  set(colors.white,.44); love.graphics.line(x,y+2,x+w,y+2)
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
  local function loadImage(paths)
    for _,path in ipairs(paths) do
      local infoOK,info=pcall(love.filesystem.getInfo,path)
      if infoOK and info then
        local imageOK,img=pcall(love.graphics.newImage,path)
        if imageOK and img then img:setFilter("linear","linear"); return img end
      end
    end
  end
  for _,n in ipairs(names) do
    -- User PNG overrides are optional; the built-in box-figure cast is the default.
    art[n]=loadImage({"assets/characters/custom/"..n..".png"})
  end
  for _,n in ipairs({"courthouse","courtroom","police-car"}) do
    photos[n]=loadImage({"assets/"..n..".jpg"})
  end
end
local function loadFonts()
  fonts.tiny=love.graphics.newFont(13); fonts.small=love.graphics.newFont(17); fonts.body=love.graphics.newFont(20)
  fonts.choice=love.graphics.newFont(16); fonts.mid=love.graphics.newFont(26); fonts.head=love.graphics.newFont(38); fonts.big=love.graphics.newFont(62); fonts.huge=love.graphics.newFont(84)
end
local function shuffleList(items)
  for i=#items,2,-1 do local j=love.math.random(i); items[i],items[j]=items[j],items[i] end
  return items
end
local function buildDocket()
  caseOrder={}
  -- Difficulty always rises; case order is shuffled inside each band.
  for tier=1,#DIFFICULTIES do
    local band={}
    for i,case in ipairs(CASES) do if case.tier==tier then band[#band+1]=i end end
    shuffleList(band)
    for _,index in ipairs(band) do caseOrder[#caseOrder+1]=index end
  end
end
local function buildQuestionDeck(case)
  questionDeck={}
  for _,source in ipairs(case.questions) do
    local question={prompt=source.prompt,choices={},correct=0}
    local optionOrder={1,2,3}; shuffleList(optionOrder)
    for slot,sourceIndex in ipairs(optionOrder) do
      question.choices[slot]=source.choices[sourceIndex]
      if sourceIndex==source.correct then question.correct=slot end
    end
    questionDeck[#questionDeck+1]=question
  end
  shuffleList(questionDeck)
end
local function beginGame()
  runMode="campaign"; love.math.setRandomSeed(os.time())
  buildDocket(); casePos=1; stagePos=1; score=0; caseCorrect=0; crossCorrect=false
  runMaxScore=#caseOrder*5; current=CASES[caseOrder[casePos]]; screen="intro"
end
local function beginDaily()
  runMode="daily"
  local date=os.date("!*t")
  local seed=date.year*10000+date.month*100+date.day
  dailyLabel=string.format("%04d-%02d-%02d UTC",date.year,date.month,date.day)
  love.math.setRandomSeed(seed); buildDocket()
  casePos=1; stagePos=1; score=0; caseCorrect=0; crossCorrect=false
  runMaxScore=#caseOrder*5; current=CASES[caseOrder[casePos]]; screen="intro"
end
local function beginPractice(index)
  runMode="practice"; love.math.setRandomSeed(os.time())
  practiceIndex=index; caseOrder={index}; casePos=1; stagePos=1; score=0; caseCorrect=0; crossCorrect=false
  runMaxScore=#CASES[index].questions+1; current=CASES[index]; screen="intro"
end
local function evidenceText(index)
  if index==1 then return current.facts end
  if index==2 then return current.item end
  return current.doctrine
end
local function startCase()
  current=CASES[caseOrder[casePos]]; buildQuestionDeck(current); stagePos=1; caseCorrect=0
  answerHistory={}
  answered=false; selected=1; feedback=""; hintUsed=false; hintVisible=false
  crossAnswered=false; crossCorrect=false; crossSelected=1; crossFeedback=""
  evidenceTab=1; evidenceViewed={false,false,false}; screen="investigation"
end
local function beginQuestions()
  screen="argument"; argumentStep=1; argumentScore=0; argumentAnswered=false; argumentChoice=1; argumentMessage=""
end
local function nextCase()
  casePos=casePos+1
  if casePos>#caseOrder then
    screen="results"
  elseif runMode=="practice" then screen="results"
  else current=CASES[caseOrder[casePos]]; stagePos=1; caseCorrect=0; crossCorrect=false; screen="intro" end
end
local function finishAnswer(index)
  if answered then
    if stagePos<#questionDeck then stagePos=stagePos+1; answered=false; selected=1; feedback=""; screen="play"
    else screen="ruling" end
    return
  end
  local stage=questionDeck[stagePos]; selected=index
  feedbackGood=index==stage.correct
  answerHistory[stagePos]=feedbackGood
  if feedbackGood then score=score+1; caseCorrect=caseCorrect+1 end
  if hintUsed and difficultyMode==2 and feedbackGood then score=math.max(0,score-1); caseCorrect=caseCorrect-1 end
  feedback=stage.choices[index].why; answered=true
end
local function nextAfterRuling() nextCase() end
local function drawBackdrop(kind)
  love.graphics.clear(colors.dark[1],colors.dark[2],colors.dark[3])
  -- Quiet ink-to-slate gradient with a fine paper grain and restrained rays.
  for i=0,24 do
    local f=i/24
    local c={colors.navy[1]+f*.025,colors.navy[2]+f*.035,colors.navy[3]+f*.045}
    set(c); love.graphics.rectangle("fill",0,i*30,W,31)
  end
  for i=1,22 do
    local x=(i*113)%W
    set(i%2==0 and colors.blue or colors.cyan,.025)
    love.graphics.polygon("fill",640,315,x-28,0,x+80,0)
  end
  set(colors.white,.025)
  for y=12,350,24 do for x=(y%48),W,24 do love.graphics.circle("fill",x,y,1) end end
  if kind=="court" and photos.courtroom then
    set(colors.white,.16); love.graphics.draw(photos.courtroom,0,0,0,W/photos.courtroom:getWidth(),H/photos.courtroom:getHeight())
    set(colors.navy,.72); love.graphics.rectangle("fill",0,0,W,H)
  elseif kind=="intro" and photos.courthouse then
    set(colors.white,.23); love.graphics.draw(photos.courthouse,0,0,0,W/photos.courthouse:getWidth(),H/photos.courthouse:getHeight())
    set(colors.navy,.69); love.graphics.rectangle("fill",0,0,W,H)
  end
  set(colors.gold,.16); love.graphics.rectangle("fill",0,0,W,3); love.graphics.rectangle("fill",0,H-3,W,3)
end
local function drawTop(label)
  rounded(28,18,7,43,3,colors.gold)
  text(label,48,25,#label>30 and fonts.tiny or fonts.small,colors.cream,"left",930)
  text("FOURTH  /  COUNSEL",W-324,27,fonts.tiny,colors.gold,"right",294)
  divider(28,73,W-56,{.64,.58,.46})
end
local function drawCharacter(name,x,y,w,h,alpha)
  if art[name] then imageFit(art[name],x,y,w,h,alpha); return end
  -- Original layered box-character art: every layer is drawn in LÖVE so the
  -- cast stays crisp and can be recolored without external sprite files.
  local witness=name:find("witness")~=nil
  local witnessOne=name:find("witness%-one")~=nil
  local witnessTwo=name:find("witness%-two")~=nil
  local counsel=name:find("counsel")~=nil
  local prosecutor=name:find("prosecutor")~=nil
  local palette = witnessOne and {{.18,.48,.43},{.10,.27,.25},{.77,.49,.34},{.20,.09,.06}}
    or witnessTwo and {{.68,.43,.20},{.37,.23,.12},{.94,.73,.55},{.24,.13,.08}}
    or counsel and {{.12,.31,.70},{.07,.16,.40},{.89,.60,.41},{.12,.07,.045}}
    or {{.31,.18,.25},{.12,.10,.17},{.72,.43,.32},{.075,.055,.07}}
  local coat,shade,skin,hair=palette[1],palette[2],palette[3],palette[4]
  local surprised=name:find("surprised") or name:find("shocked") or name:find("worry")
  local angry=name:find("angry") or name:find("shout")
  local doubtful=name:find("doubt")
  local s=math.min(w/180,h/260)
  local phase=animTime*2.7+x*.012
  local bob=math.sin(phase)*2.2*s
  local cx=x+w/2; local top=y+h-260*s+bob
  local function box(bx,by,bw,bh,c,r)
    set(c,alpha or 1); love.graphics.rectangle("fill",bx,by,bw,bh,r or 3)
    set({.035,.045,.075},(alpha or 1)*.9); love.graphics.setLineWidth(math.max(1,2*s)); love.graphics.rectangle("line",bx,by,bw,bh,r or 3)
  end
  local function polygon(points,c)
    set(c,alpha or 1); love.graphics.polygon("fill",unpack(points))
    set({.035,.045,.075},(alpha or 1)*.88); love.graphics.setLineWidth(math.max(1,2*s)); love.graphics.polygon("line",unpack(points))
  end
  local shoulder=counsel and 73 or (witnessOne and 72 or 62)
  local faceHalf=counsel and 43 or (prosecutor and 40 or (witnessOne and 46 or 40))
  -- The attorney and prosecutor wear sharply cut suits; witnesses wear casual
  -- knit layers with visibly different shapes, palettes and accessories.
  box(cx-19*s,top+72*s,38*s,36*s,skin)
  if witnessTwo then
    box(cx-67*s,top+97*s,134*s,158*s,shade,22*s) -- soft hoodie silhouette
    box(cx-57*s,top+103*s,114*s,139*s,coat,18*s)
    box(cx-26*s,top+99*s,52*s,38*s,{.82,.66,.43},14*s) -- hood opening
  elseif witnessOne then
    polygon({cx-shoulder*s,top+112*s,cx-57*s,top+96*s,cx+57*s,top+96*s,cx+shoulder*s,top+112*s,cx+66*s,top+253*s,cx-66*s,top+253*s},shade)
    box(cx-57*s,top+105*s,114*s,138*s,coat,5*s)
    box(cx-28*s,top+103*s,56*s,72*s,{.91,.79,.64},3*s)
  elseif counsel then
    polygon({cx-shoulder*s,top+112*s,cx-53*s,top+96*s,cx+53*s,top+96*s,cx+shoulder*s,top+112*s,cx+68*s,top+253*s,cx-68*s,top+253*s},shade)
    box(cx-58*s,top+105*s,116*s,138*s,coat,3*s)
    box(cx-24*s,top+104*s,48*s,93*s,{.98,.96,.86},2*s)
  else
    polygon({cx-shoulder*s,top+111*s,cx-51*s,top+97*s,cx+51*s,top+97*s,cx+shoulder*s,top+111*s,cx+58*s,top+253*s,cx-58*s,top+253*s},shade)
    box(cx-51*s,top+105*s,102*s,138*s,coat,3*s)
    box(cx-23*s,top+104*s,46*s,87*s,{.99,.97,.90},2*s)
  end
  if counsel or prosecutor then
    local tie=prosecutor and colors.gold or { .79,.13,.22 }
    polygon({cx-12*s,top+109*s,cx+12*s,top+109*s,cx+10*s,top+132*s,cx+17*s,top+188*s,cx,top+202*s,cx-17*s,top+188*s,cx-10*s,top+132*s},tie)
  elseif witnessOne then
    -- Casual overshirt seams and chest pocket.
    set({.81,.91,.85},alpha or 1); love.graphics.setLineWidth(2*s)
    love.graphics.line(cx-38*s,top+112*s,cx-35*s,top+239*s); love.graphics.line(cx+38*s,top+112*s,cx+35*s,top+239*s)
    box(cx+16*s,top+147*s,23*s,25*s,{.13,.34,.31},2*s)
  else
    -- Hoodie drawstrings and a small stitched emblem.
    set({.95,.78,.46},alpha or 1); love.graphics.setLineWidth(2*s)
    love.graphics.line(cx-9*s,top+119*s,cx-13*s,top+158*s); love.graphics.line(cx+9*s,top+119*s,cx+13*s,top+158*s)
    set({.97,.77,.34},alpha or 1); love.graphics.circle("fill",cx+31*s,top+195*s,5*s)
  end
  if prosecutor then
    box(cx+31*s,top+118*s,14*s,25*s,{.93,.91,.82},2*s) -- pocket square
  elseif counsel then
    set(colors.gold,alpha or 1); love.graphics.circle("fill",cx+40*s,top+150*s,5*s)
    set(colors.ink,alpha or 1); love.graphics.circle("fill",cx+40*s,top+150*s,2*s) -- scales pin
  end
  -- Detached hands: deliberately no arms.
  local gesture=angry and math.abs(math.sin(phase*1.7))*9*s or (surprised and math.sin(phase*1.3)*5*s or math.sin(phase)*2*s)
  local handY=top+149*s-gesture
  box(cx-(shoulder+21)*s,handY,29*s,38*s,skin,8*s); box(cx+(shoulder-8)*s,handY,29*s,38*s,skin,8*s)
  set({1,.81,.64},alpha or 1); love.graphics.rectangle("fill",cx-86*s,handY+5*s,5*s,21*s,2*s); love.graphics.rectangle("fill",cx+81*s,handY+5*s,5*s,21*s,2*s)
  -- Face base, shadow plane, cheeks, brows, eyes, nose and mouth.
  box(cx-faceHalf*s,top+8*s,faceHalf*2*s,79*s,skin,8*s)
  box(cx-faceHalf*s+5*s,top+57*s,faceHalf*2*s-10*s,24*s,{.70,.43,.32},5*s)
  box(cx-37*s,top+51*s,18*s,10*s,{.98,.76,.59},4*s); box(cx+19*s,top+51*s,18*s,10*s,{.98,.76,.59},4*s)
  if witnessTwo then
    -- Curly fringe and round glasses make the second witness distinct even
    -- when their expression changes during testimony.
    for _,dx in ipairs({-34,-20,-5,11,27}) do set(hair,alpha or 1); love.graphics.circle("fill",cx+dx*s,top+10*s,12*s) end
  elseif prosecutor then
    box(cx-42*s,top-2*s,86*s,19*s,hair,3*s)
    polygon({cx+5*s,top+3*s,cx+44*s,top-2*s,cx+37*s,top+30*s,cx+25*s,top+24*s},hair)
  elseif witnessOne then
    box(cx-47*s,top+1*s,91*s,18*s,hair,9*s)
    box(cx-47*s,top+9*s,15*s,33*s,hair,5*s)
  else
    box(cx-44*s,top-1*s,88*s,19*s,hair,3*s)
    box(cx-44*s,top+5*s,15*s,30*s,hair,3*s)
  end
  local brow=angry and colors.red or hair
  box(cx-31*s,top+31*s,24*s,5*s,brow,2*s); box(cx+7*s,top+31*s,24*s,5*s,brow,2*s)
  local blink=math.abs(math.sin(animTime*1.1+x*.022))>.995
  local eyeH=surprised and 11 or (blink and 2 or 6)
  box(cx-27*s,top+39*s,13*s,eyeH,{.98,.98,.92},3*s); box(cx+14*s,top+39*s,13*s,eyeH,{.98,.98,.92},3*s)
  set(colors.ink,alpha or 1); love.graphics.circle("fill",cx-20*s,top+44*s,3.2*s); love.graphics.circle("fill",cx+21*s,top+44*s,3.2*s)
  box(cx-3*s,top+43*s,6*s,14*s,{.68,.40,.31},2*s)
  if witnessTwo then
    set({.13,.12,.10},alpha or 1); love.graphics.setLineWidth(2.4*s)
    love.graphics.rectangle("line",cx-31*s,top+36*s,23*s,19*s,5*s); love.graphics.rectangle("line",cx+8*s,top+36*s,23*s,19*s,5*s)
    love.graphics.line(cx-8*s,top+44*s,cx+8*s,top+44*s)
  end
  local mouthY=top+(surprised and 65 or 66)*s
  if surprised then set({.30,.05,.06},alpha or 1); love.graphics.ellipse("fill",cx,mouthY,8*s,11*s)
  elseif angry then set({.36,.04,.05},alpha or 1); love.graphics.ellipse("fill",cx,mouthY,12*s,(5+math.abs(math.sin(animTime*9+x)) * 4)*s)
  elseif doubtful then set({.34,.08,.09},alpha or 1); love.graphics.line(cx-11*s,mouthY+4*s,cx+11*s,mouthY-2*s)
  else set({.34,.08,.09},alpha or 1); love.graphics.line(cx-10*s,mouthY,cx+10*s,mouthY) end
  -- Lapel highlights provide a final foreground layer.
  if counsel or prosecutor then
    set({.78,.84,1},(alpha or 1)*.78)
    polygon({cx-53*s,top+108*s,cx-30*s,top+132*s,cx-45*s,top+167*s},shade)
    polygon({cx+53*s,top+108*s,cx+30*s,top+132*s,cx+45*s,top+167*s},shade)
  else
    set({1,.96,.80},(alpha or 1)*.22); love.graphics.rectangle("fill",cx-4*s,top+179*s,8*s,64*s)
  end
end
local function drawLogo(y)
  center("FOURTH",y,fonts.huge,colors.cream)
  center("COUNSEL",y+74,fonts.big,colors.gold)
  love.graphics.setLineWidth(2); set(colors.gold,.8); love.graphics.line(445,y+147,835,y+147)
  set(colors.gold); love.graphics.polygon("fill",640,y+142,646,y+147,640,y+152,634,y+147)
  center("THE PEOPLE v. YOUR JUDGMENT",y+161,fonts.tiny,colors.muted)
end
local LEARN_VIEW_Y, LEARN_VIEW_H, LEARN_MAX_SCROLL = 99, 507, 892
local function drawLearnIllustration(kind,x,y,w,h)
  rounded(x,y,w,h,10,{.88,.86,.79})
  set({.80,.77,.69},.8); love.graphics.rectangle("line",x,y,w,h,10)
  local base=y+h-20
  set({.77,.72,.61}); love.graphics.rectangle("fill",x+12,base,w-24,2)
  if kind=="colonial" then
    -- A quiet, original illustration of a colonial house and a broad search warrant.
    set({.72,.65,.51}); love.graphics.polygon("fill",x+31,base-77,x+84,base-120,x+137,base-77)
    set({.70,.69,.59}); love.graphics.rectangle("fill",x+39,base-77,90,75)
    set({.30,.39,.40}); love.graphics.rectangle("fill",x+52,base-65,21,22,2)
    set({.30,.39,.40}); love.graphics.rectangle("fill",x+94,base-65,21,22,2)
    set({.42,.31,.24}); love.graphics.rectangle("fill",x+76,base-40,18,38)
    set({.82,.72,.53}); love.graphics.circle("fill",x+227,base-79,35)
    set({.97,.94,.86}); love.graphics.rectangle("fill",x+207,base-102,39,48,3)
    set({.55,.31,.22}); love.graphics.rectangle("fill",x+213,base-93,27,3,1)
    for i=0,2 do set({.64,.62,.56}); love.graphics.rectangle("fill",x+213,base-84+i*8,25,2,1) end
    set(colors.gold); love.graphics.circle("fill",x+235,base-64,6)
  elseif kind=="warrant" then
    set({.98,.96,.89}); love.graphics.rectangle("fill",x+22,y+17,w-44,h-34,5)
    set({.72,.66,.53}); love.graphics.rectangle("line",x+22,y+17,w-44,h-34,5)
    set(colors.red,.9); love.graphics.circle("line",x+w-51,y+52,19); love.graphics.circle("line",x+w-51,y+52,14)
    text("WARRANT",x+39,y+29,fonts.tiny,colors.blue)
    for i=0,3 do set({.70,.69,.64}); love.graphics.rectangle("fill",x+39,y+56+i*12,w-116-(i%2)*34,2,1) end
    set(colors.gold); love.graphics.polygon("fill",x+w-51,y+39,x+w-46,y+50,x+w-51,y+61,x+w-56,y+50)
  elseif kind=="phone" then
    rounded(x+44,y+12,w-88,h-24,14,{.14,.19,.23})
    rounded(x+52,y+22,w-104,h-44,9,{.82,.87,.83})
    set({.57,.68,.64}); love.graphics.setLineWidth(3)
    love.graphics.line(x+73,y+64,x+112,y+47,x+143,y+76,x+188,y+51,x+217,y+67)
    for _,p in ipairs({{73,64},{112,47},{143,76},{188,51},{217,67}}) do set(colors.red); love.graphics.circle("fill",x+p[1],y+p[2],4) end
    set(colors.gold); love.graphics.circle("fill",x+w/2,y+h-25,4)
    set(colors.blue); love.graphics.rectangle("fill",x+w-76,y+h-52,30,22,5)
    love.graphics.polygon("fill",x+w-69,y+h-52,x+w-66,y+h-64,x+w-57,y+h-64,x+w-54,y+h-52)
  elseif kind=="home" then
    set({.60,.67,.64}); love.graphics.polygon("fill",x+30,y+85,x+w/2,y+28,x+w-30,y+85)
    set({.93,.91,.85}); love.graphics.rectangle("fill",x+48,y+82,w-96,h-101)
    set({.41,.48,.47}); love.graphics.rectangle("fill",x+w/2-16,y+98,32,h-117,2)
    set(colors.gold); love.graphics.circle("fill",x+w/2+8,y+122,3)
    set(colors.red); love.graphics.circle("fill",x+w-55,y+67,22)
    set(colors.paper); love.graphics.polygon("fill",x+w-55,y+53,x+w-44,y+58,x+w-47,y+72,x+w-55,y+79,x+w-63,y+72,x+w-66,y+58)
  elseif kind=="scales" then
    set(colors.gold); love.graphics.setLineWidth(4)
    love.graphics.line(x+w/2,y+31,x+w/2,y+h-36); love.graphics.line(x+w/2-48,y+52,x+w/2+48,y+52)
    love.graphics.line(x+w/2-38,y+53,x+w/2-52,y+88); love.graphics.line(x+w/2-38,y+53,x+w/2-23,y+88)
    love.graphics.line(x+w/2+38,y+53,x+w/2+23,y+88); love.graphics.line(x+w/2+38,y+53,x+w/2+52,y+88)
    love.graphics.arc("line","open",x+w/2-52,y+83,18,0,math.pi); love.graphics.arc("line","open",x+w/2+52,y+83,18,0,math.pi)
    love.graphics.line(x+w/2-20,y+h-36,x+w/2+20,y+h-36)
    love.graphics.line(x+w/2-32,y+h-30,x+w/2+32,y+h-30)
  end
end
local function drawLearn()
  drawBackdrop("intro"); drawTop("LEARN  /  AMENDMENT IV")
  panel(70,88,1140,574,14,colors.paper,{.67,.58,.43})
  -- Fixed title and help; the lesson itself scrolls independently.
  text("THE FOURTH AMENDMENT",96,99,fonts.head,colors.ink)
  text("A guide to searches, seizures, and the rules that protect privacy.",98,146,fonts.tiny,colors.blue)
  divider(96,169,1084)
  love.graphics.setScissor(92,LEARN_VIEW_Y,1090,LEARN_VIEW_H)
  love.graphics.push(); love.graphics.translate(0,-learnScroll)

  rounded(96,183,1084,102,10,{.12,.17,.21})
  text("RATIFIED DECEMBER 15, 1791",118,199,fonts.tiny,colors.gold)
  text("One of the first ten amendments in the Bill of Rights.",118,222,fonts.small,colors.cream)
  text("It protects people from unreasonable government searches and seizures.",118,249,fonts.tiny,colors.muted)
  drawLearnIllustration("scales",1007,192,145,84)

  rounded(96,300,1084,194,10,{.94,.92,.87})
  text("WHY WAS IT PROPOSED?",118,316,fonts.small,colors.red)
  text("Before independence, British officers used writs of assistance and broad general warrants to search for smuggled goods. These orders could leave the place and objects to be searched largely to an officer's discretion. Colonists objected to that kind of arbitrary search. During the debates over ratifying the Constitution, several states called for written protections; James Madison introduced amendments in the First Congress.",118,345,fonts.tiny,colors.ink,"left",688)
  text("HISTORICAL CONTEXT  ·  NATIONAL ARCHIVES; U.S. REPORTS",118,465,fonts.tiny,colors.blue)
  drawLearnIllustration("colonial",843,323,310,151)

  rounded(96,508,1084,249,10,{.94,.92,.87})
  text("WHAT DID IT CHANGE?",118,524,fonts.small,colors.red)
  text("The Constitution's rule",118,550,fonts.tiny,colors.blue)
  text("The right of the people to be secure in their persons, houses, papers, and effects, against unreasonable searches and seizures, shall not be violated, and no Warrants shall issue, but upon probable cause, supported by Oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized.",118,570,fonts.tiny,colors.ink,"left",680)
  divider(118,681,679)
  text("A warrant must be grounded in probable cause and describe the search with particularity. Courts also recognize exceptions to the warrant requirement; every search is judged by the facts and applicable doctrine.",118,693,fonts.tiny,colors.blue,"left",680)
  drawLearnIllustration("warrant",843,537,310,151)

  text("FOUR IDEAS TO REMEMBER",98,778,fonts.small,colors.red)
  local ideas={
    {"01  WHO IS PROTECTED","People and their private spaces and belongings."},
    {"02  REASONABLENESS","The facts and setting matter to the analysis."},
    {"03  WARRANT DETAILS","Probable cause, oath, and particular description."},
    {"04  LIMITED EXCEPTIONS","Some searches may proceed without a warrant."}
  }
  for i,item in ipairs(ideas) do
    local xx=96+(i-1)*274
    rounded(xx,811,260,105,9,{.94,.92,.87})
    rounded(xx+14,825,33,27,5,colors.navy)
    text(string.sub(item[1],1,2),xx+14,831,fonts.tiny,colors.gold,"center",33)
    text(string.sub(item[1],5),xx+55,827,fonts.tiny,colors.red,"left",191)
    text(item[2],xx+16,864,fonts.tiny,colors.ink,"left",228)
  end

  rounded(96,936,1084,201,10,{.12,.17,.21})
  text("WHY IT STILL MATTERS",118,952,fonts.small,colors.gold)
  text("The same protection applies to modern evidence, including phones and location records. In Riley v. California (2014), the Supreme Court generally required a warrant to search digital information on a phone seized during an arrest. In Carpenter v. United States (2018), it required a warrant for the historical cell-site records at issue. These are specific rulings, not a rule that every digital search is identical. The Fourth Amendment also applies to state and local governments through the Fourteenth Amendment.",118,982,fonts.tiny,colors.cream,"left",700)
  text("MODERN EXAMPLES  ·  RILEY (2014)  ·  CARPENTER (2018)",118,1112,fonts.tiny,colors.gold)
  drawLearnIllustration("phone",868,974,284,142)

  text("PICTURES TO THINK WITH",98,1161,fonts.small,colors.red)
  text("Original illustrations · no external image downloads",98,1187,fonts.tiny,colors.blue)
  local gallery={
    {"home","A home is a protected space; facts and exceptions still matter."},
    {"scales","Courts weigh the specific circumstances of a search."},
    {"phone","Digital records can reveal a detailed picture of a person's life."}
  }
  for i,item in ipairs(gallery) do
    local xx=96+(i-1)*365
    drawLearnIllustration(item[1],xx,1211,345,126)
    text(item[2],xx+3,1344,fonts.tiny,colors.ink,"left",338)
  end

  rounded(96,1396,1084,102,10,{.94,.92,.87})
  text("EXPLORE THE PRIMARY SOURCES",118,1412,fonts.tiny,colors.red)
  text("National Archives: Bill of Rights and ratification history  ·  U.S. Reports: Verdugo-Urquidez  ·  Riley v. California  ·  Carpenter v. United States  ·  Congress.gov Constitution Annotated",118,1438,fonts.tiny,colors.ink,"left",1027)

  love.graphics.pop(); love.graphics.setScissor()
  -- Scroll track and fixed footer controls.
  rounded(1188,LEARN_VIEW_Y,4,LEARN_VIEW_H,2,{.83,.81,.76})
  local thumbH=math.max(48,LEARN_VIEW_H*LEARN_VIEW_H/(1498-LEARN_VIEW_Y))
  local thumbY=LEARN_VIEW_Y+(LEARN_VIEW_H-thumbH)*(learnScroll/LEARN_MAX_SCROLL)
  rounded(1186,thumbY,8,thumbH,4,colors.gold)
  divider(94,615,1092)
  text("SCROLL OR USE ↑ / ↓  ·  PAGE UP / PAGE DOWN  ·  HOME / END",98,630,fonts.tiny,colors.blue)
  rounded(1040,622,138,30,6,colors.navy)
  text("BACK  ·  ESC",1040,629,fonts.tiny,colors.gold,"center",138)
end
local function drawTitle()
  drawBackdrop("intro")
  drawCharacter("counsel-neutral",18,150,300,510,.96)
  drawCharacter("prosecutor-neutral",962,142,290,520,.94)
  drawLogo(55)
  panel(365,247,550,412,15,{.085,.115,.17},{.65,.56,.40})
  text("SELECT A DOCKET",405,264,fonts.small,colors.gold)
  text("Choose how you want to take the case.",405,288,fonts.tiny,colors.muted)
  local entries={{"1  CAMPAIGN","Twelve escalating cases"},{"2  DAILY DOCKET","Same randomized docket worldwide"},{"3  PRACTICE","Choose a case and drill the rule"},{"4  DOCTRINE NOTEBOOK","Review cases, rules and outcomes"},{"5  LEARN","History, protections and impact today"}}
  for i,e in ipairs(entries) do
    local yy=313+(i-1)*49
    rounded(397,yy,486,43,7,{.94,.92,.86})
    rounded(406,yy+6,31,31,5,colors.navy)
    text(tostring(i),406,yy+13,fonts.tiny,colors.gold,"center",31)
    text(e[1]:sub(4),450,yy+3,fonts.tiny,colors.ink)
    text(e[2],450,yy+21,fonts.tiny,colors.blue)
    text("›",850,yy+1,fonts.mid,colors.gold,"center",24)
  end
  rounded(500,572,280,35,6,{.13,.16,.21})
  text("DIFFICULTY  ·  "..DIFFICULTY_NAMES[difficultyMode].."  (D)",510,582,fonts.tiny,colors.cream,"center",260)
  center("Press 1–5 to choose  ·  D changes difficulty",680,fonts.tiny,colors.muted)
end
local function drawIntro()
  drawBackdrop("intro"); drawTop("LEVEL  "..casePos.." / "..#caseOrder.."  •  "..DIFFICULTIES[current.tier])
  drawCharacter(current.witness or "witness-one",18,127,320,485,.95)
  panel(298,104,930,520,15,colors.paper,{.67,.58,.43})
  rounded(298,104,930,7,4,colors.gold)
  rounded(326,127,230,30,5,{.91,.88,.81})
  text(current.tag,339,135,fonts.tiny,colors.red)
  text("CASE  "..string.format("%02d",casePos),1154,135,fonts.tiny,colors.blue,"right",44)
  text(current.title,328,175,fonts.head,colors.ink,"left",850)
  text(current.setting,331,223,fonts.small,colors.blue,"left",830)
  rounded(1017,218,178,30,6,{.91,.88,.81})
  text(DIFFICULTIES[current.tier],1028,226,fonts.tiny,colors.red,"center",156)
  divider(328,262,867)
  text("THE FACTS",330,280,fonts.tiny,colors.red)
  text(current.facts,330,306,fonts.body,colors.ink,"left",850)
  divider(328,428,867)
  text("EVIDENCE AT ISSUE",330,445,fonts.tiny,colors.red)
  text(current.item,330,469,fonts.mid,colors.ink,"left",830)
  text(difficultyMode==3 and "EXPERT MODE  /  DOCTRINE NOTES HIDDEN" or current.doctrine,330,519,fonts.tiny,colors.blue,"left",835)
  rounded(920,562,275,43,7,colors.navy)
  text("OPEN EVIDENCE DESK  →",932,575,fonts.tiny,colors.gold,"center",250)
  text("ENTER OR CLICK  ·  REVIEW THE RECORD",18,674,fonts.tiny,colors.muted)
end

local function drawInvestigation()
  drawBackdrop("intro"); drawTop("INVESTIGATION  •  LEVEL "..casePos.." / "..#caseOrder)
  panel(80,100,1120,550,14,colors.paper,{.67,.58,.43})
  text("THE EVIDENCE DESK",112,117,fonts.head,colors.ink)
  text("Review each record. Use the file to test the witness's account.",114,162,fonts.small,colors.blue)
  divider(114,191,1020)
  for i,label in ipairs(EVIDENCE_LABELS) do
    local x=114+(i-1)*350
    local fill=evidenceTab==i and colors.navy or {.90,.89,.84}
    rounded(x,207,322,54,7,fill)
    rounded(x,207,5,54,2,evidenceViewed[i] and colors.green or (evidenceTab==i and colors.gold or {.72,.69,.62}))
    text((evidenceViewed[i] and "✓  " or string.format("%02d  ",i))..label,x+16,224,fonts.tiny,evidenceTab==i and colors.cream or colors.ink,"center",294)
  end
  local labels={"OFFICIAL CASE FILE","PROPERTY / RECORD REVIEW","CONTROLLING PRECEDENT"}
  panel(114,280,1020,265,10,{.925,.92,.86},{.82,.78,.68})
  rounded(114,280,7,265,4,colors.gold)
  text(labels[evidenceTab],144,302,fonts.tiny,colors.red)
  divider(144,330,950)
  text(evidenceText(evidenceTab),144,352,fonts.body,colors.ink,"left",948)
  rounded(114,576,220,41,6,{.88,.86,.80}); text("←  PREVIOUS FILE",114,589,fonts.tiny,colors.navy,"center",220)
  rounded(348,576,220,41,6,{.88,.86,.80}); text("NEXT FILE  →",348,589,fonts.tiny,colors.navy,"center",220)
  local ready=evidenceViewed[1] and evidenceViewed[2] and evidenceViewed[3]
  rounded(847,576,287,41,6,ready and colors.green or {.75,.75,.71})
  text(ready and "CALL THE WITNESS  →" or "REVIEW ALL THREE FILES",847,589,fonts.tiny,colors.white,"center",287)
  center("← / → change file   ·   Enter marks it reviewed",628,fonts.tiny,colors.blue)
end

local function drawCross()
  drawBackdrop("court"); drawTop("CROSS-EXAMINATION  •  PRESENT YOUR EXHIBIT")
  local witnessArt=current.witness or "witness-one"
  if crossAnswered then
    if crossCorrect then witnessArt=witnessArt..(witnessArt=="witness-one" and "-shocked" or "-angry")
    else witnessArt=witnessArt..(witnessArt=="witness-one" and "-doubt" or "-worry") end
  end
  drawCharacter(witnessArt,60,120,335,470,.98)
  panel(324,112,894,482,14,colors.paper,{.67,.58,.43})
  rounded(324,112,894,6,4,colors.red); text("WITNESS STATEMENT",354,137,fonts.tiny,colors.red)
  text(current.crossSpeaker,354,166,fonts.mid,colors.ink,"left",820)
  text("TESTIMONY",358,221,fonts.tiny,colors.blue)
  text("“"..current.crossStatement.."”",358,249,fonts.mid,colors.ink,"left",808)
  text("SELECT AN EXHIBIT",358,346,fonts.tiny,colors.red)
  text("Which record tests that statement?",520,346,fonts.tiny,colors.blue)
  for i,label in ipairs(EVIDENCE_LABELS) do
    local yy=381+(i-1)*55
    local c=colors.white
    if crossAnswered and i==crossSelected then c=crossCorrect and {.77,.97,.83} or {1,.80,.77} elseif not crossAnswered and i==crossSelected then c={.83,.91,1} end
    rounded(358,yy,814,45,6,c); text(string.format("%02d",i),375,yy+12,fonts.tiny,colors.gold,"left",28); text(label,414,yy+12,fonts.small,colors.ink,"left",740)
  end
  if crossAnswered then
    text(crossFeedback,359,560,fonts.tiny,crossCorrect and colors.green or colors.red,"left",805)
    rounded(901,626,271,48,9,colors.gold); text("BUILD YOUR ARGUMENT  →",901,639,fonts.tiny,colors.navy,"center",271)
  else text("Select the strongest exhibit, then Enter",359,578,fonts.tiny,colors.blue) end
end

local function argumentChoices()
  if argumentStep==1 then return {"Use the case facts and identify what officers did.","Skip the police conduct and attack the defendant's character.","Rely on facts from a different case."} end
  if argumentStep==2 then return {"Apply the rule stated in the controlling precedent.","Use a rule from an unrelated doctrine.","Assume police may search anything they can reach."} end
  if argumentStep==3 then return {"Explain how the conduct crossed that rule's limit.","Concede the search was lawful without analysis.","Argue that every police search is unconstitutional."} end
  return {"Seek suppression of evidence tied to the unlawful search.","Ask to dismiss the whole case automatically.","Concede suppression is unavailable without a violation."}
end
local function argumentCorrectChoice()
  if argumentStep<=2 then return 1 end
  if argumentStep==3 then return current.merit=="suppress" and 1 or 2 end
  return current.merit=="suppress" and 1 or 3
end
local function submitArgument(choice)
  if argumentAnswered then
    argumentStep=argumentStep+1; argumentAnswered=false; argumentChoice=1; argumentMessage=""
    if argumentStep>4 then screen="play" end
    return
  end
  argumentChoice=choice; argumentAnswered=true
  local good=choice==argumentCorrectChoice()
  if good then argumentScore=argumentScore+1 end
  if argumentStep==3 and current.merit=="deny" and good then
    argumentMessage="Correct: identify why this search stayed within the doctrine."
  elseif argumentStep==4 and current.merit=="deny" and good then
    argumentMessage="Correct: without a violation, suppression is not the proper remedy."
  else
    argumentMessage=good and "Strong link. Your theory connects the record to the governing rule." or "This link does not fit the record. Revisit the evidence and keep the remedy precise."
  end
end
local function drawArgument()
  drawBackdrop("court"); drawTop("BUILD YOUR MOTION  •  LINK THE ARGUMENT")
  local titles={"1  WHAT DID POLICE DO?","2  WHICH RULE CONTROLS?","3  WHY WAS IT LAWFUL OR UNLAWFUL?","4  WHAT RELIEF FITS?"}
  panel(112,105,1056,510,14,colors.paper,{.67,.58,.43})
  text("ARGUMENT BUILDER",150,122,fonts.head,colors.ink)
  divider(154,178,970)
  text(titles[argumentStep],154,195,fonts.mid,colors.red,"left",950)
  for i,label in ipairs(argumentChoices()) do
    local yy=258+(i-1)*75; local c={.93,.92,.87}
    if argumentAnswered and i==argumentChoice then c=argumentChoice==argumentCorrectChoice() and {.77,.97,.83} or {1,.80,.77} elseif not argumentAnswered and i==argumentChoice then c={.83,.91,1} end
    rounded(154,yy,970,61,7,c); rounded(169,yy+13,34,34,5,colors.navy); text(i,169,yy+21,fonts.tiny,colors.gold,"center",34); text(label,221,yy+17,fonts.small,colors.ink,"left",885)
  end
  if argumentAnswered then text(argumentMessage,158,511,fonts.tiny,argumentChoice==argumentCorrectChoice() and colors.green or colors.red,"left",940) end
  rounded(880,553,244,43,9,colors.gold); text(argumentAnswered and "NEXT LINK  →" or "LOCK IN LINK  →",880,565,fonts.tiny,colors.navy,"center",244)
  center("1–3 choose • Enter confirms / advances",587,fonts.tiny,colors.blue)
end

local function drawPractice()
  drawBackdrop("intro"); drawTop("PRACTICE DOCKET")
  panel(88,105,1104,535,14,colors.paper,{.67,.58,.43}); text("Choose a case to rehearse",122,122,fonts.head,colors.ink)
  text("One focused hearing, with feedback after each decision.",125,169,fonts.small,colors.blue)
  divider(120,192,1030)
  for i,c in ipairs(CASES) do
    local col=(i-1)%3; local row=math.floor((i-1)/3); local x=120+col*350; local y=205+row*96
    rounded(x,y,320,78,7,i==practiceIndex and {.88,.83,.69} or {.92,.91,.86})
    rounded(x+10,y+13,38,38,5,i==practiceIndex and colors.navy or {.79,.77,.70})
    text(string.format("%02d",i),x+10,y+24,fonts.tiny,i==practiceIndex and colors.gold or colors.ink,"center",38)
    text(c.title,x+59,y+11,fonts.tiny,colors.ink,"left",248)
    text(DIFFICULTIES[c.tier].."  ·  "..c.tag,x+59,y+43,fonts.tiny,colors.blue,"left",248)
  end
  rounded(472,564,336,48,9,colors.gold); text("START SELECTED CASE  →",472,578,fonts.small,colors.navy,"center",336)
  center("Arrow keys choose • Enter begins • Esc returns",622,fonts.tiny,colors.blue)
end

local function drawNotebook()
  drawBackdrop("intro"); drawTop("DOCTRINE NOTEBOOK")
  panel(65,92,1150,560,14,colors.paper,{.67,.58,.43})
  text("FIELD GUIDE",95,104,fonts.head,colors.ink)
  text("PRECEDENT  /  CASE NOTES",99,153,fonts.tiny,colors.blue)
  local c=CASES[notebookIndex]
  text("CASES",100,171,fonts.small,colors.red)
  for i,entry in ipairs(CASES) do
    local yy=205+(i-1)*31
    local active=i==notebookIndex
    if active then rounded(92,yy-3,347,29,4,{.88,.84,.72}) end
    text(string.format("%02d",i),101,yy,fonts.tiny,active and colors.red or colors.blue,"left",30)
    text(entry.title,132,yy,fonts.tiny,active and colors.ink or {.35,.37,.38},"left",304)
  end
  rounded(463,169,1,436,1,{.78,.81,.82})
  text(c.title,493,170,fonts.head,colors.ink,"left",675)
  text(c.doctrine,496,224,fonts.mid,colors.blue,"left",665)
  text("KEY FACTS",496,275,fonts.tiny,colors.red)
  text(c.facts,496,300,fonts.tiny,colors.ink,"left",654)
  divider(496,415,650)
  text("EVIDENCE",496,430,fonts.tiny,colors.red)
  text(c.item,496,454,fonts.small,colors.ink,"left",654)
  text("PRACTICE RULING",496,491,fonts.tiny,colors.red)
  text(c.outcome,496,516,fonts.tiny,colors.ink,"left",654)
  rounded(942,590,235,43,6,colors.navy); text("PRACTICE THIS CASE",952,603,fonts.tiny,colors.gold,"center",215)
  text("↑ / ↓ browse • Enter practices",95,615,fonts.tiny,colors.blue)
end
local function promptLineCount()
  local stage=questionDeck[stagePos]
  if not stage then return 1 end
  local _,wrapped=fonts.body:getWrap(stage.prompt,1070)
  return math.max(1,#wrapped)
end
local function answerRect(i)
  local promptBottom=426+promptLineCount()*fonts.body:getHeight()
  local top=math.max(hintVisible and promptBottom+27 or 486,promptBottom+11)
  return 100,top+(i-1)*48,1080,43
end
local function drawCourt()
  drawBackdrop("court"); drawTop("LEVEL "..casePos.." / "..#caseOrder.."  •  Q "..stagePos.." / "..#questionDeck)
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
  panel(72,365,1135,343,14,colors.paper,{.67,.58,.43})
  rounded(72,365,1135,5,3,colors.gold)
  rounded(72,375,1135,42,5,colors.navy)
  local stage=questionDeck[stagePos]
  text("THE COURT WANTS YOUR THEORY",98,388,fonts.tiny,colors.gold)
  text(stage.prompt,100,426,fonts.body,colors.ink,"left",1070)
  if hintVisible and difficultyMode~=3 then
    local hintY=426+promptLineCount()*fonts.body:getHeight()+2
    rounded(100,hintY,1080,18,4,{.89,.91,.88}); text("HINT  ·  "..current.doctrine,112,hintY+1,fonts.tiny,colors.blue,"left",1040)
  end
  for i,ch in ipairs(stage.choices) do
    local x,y,w,h=answerRect(i); local c=colors.white
    if answered and i==selected then c=feedbackGood and {.77,.97,.83} or {1,.80,.77} elseif not answered and i==selected then c={.83,.91,1} end
    rounded(x,y,w,h,9,c)
    set(not answered and i==selected and colors.blue or colors.ink)
    love.graphics.setLineWidth(not answered and i==selected and 3 or 1); love.graphics.rectangle("line",x,y,w,h,9)
    rounded(x+12,y+5,32,31,6,not answered and i==selected and colors.blue or colors.navy)
    text(tostring(i),x+12,y+11,fonts.tiny,colors.white,"center",32)
    text(ch.text,x+58,y+5,fonts.choice,colors.ink,"left",w-72)
  end
  if answered then
    rounded(108,642,1065,53,7,feedbackGood and colors.green or colors.red)
    local label=(feedbackGood and "OBJECTION SUSTAINED!  " or "OBJECTION OVERRULED.  ")..feedback
    text(label,126,650,fonts.tiny,colors.white,"left",1030)
    rounded(1080,17,166,43,8,colors.gold); text(stagePos==#questionDeck and "SEE RULING →" or "CONTINUE →",1080,28,fonts.tiny,colors.navy,"center",166)
  else
    text(difficultyMode==3 and "Expert: hints disabled" or "Choose a response  •  H shows doctrine hint",101,667,fonts.tiny,colors.muted)
  end
end
local function drawRuling()
  drawBackdrop("court"); drawTop("THE COURT HAS RULED")
  local good=caseCorrect>=3 and crossCorrect and argumentScore>=3
  local granted=current.merit=="suppress" and good
  local heading=current.merit=="deny" and "EVIDENCE ADMITTED" or (granted and "SUPPRESSION GRANTED" or "MOTION DENIED")
  local rulingColor=granted and colors.green or (current.merit=="deny" and good and colors.green or colors.red)
  drawCharacter(good and "counsel-shout" or "counsel-surprised",8,104,455,590,.94)
  panel(350,132,858,496,14,colors.paper,{.67,.58,.43})
  rounded(350,132,858,6,4,rulingColor)
  text(heading,386,151,fonts.head,rulingColor,"left",770)
  text(current.title,390,231,fonts.mid,colors.ink,"left",770)
  text("YOUR PERFORMANCE",390,280,fonts.small,colors.blue)
  for i=1,#questionDeck do
    local x=392+(i-1)*71
    local mark=answerHistory[i]==nil and {.80,.79,.74} or (answerHistory[i] and colors.green or colors.red)
    rounded(x,319,54,14,7,mark)
  end
  text(caseCorrect.." / "..#questionDeck.." calls  •  exhibit "..(crossCorrect and "proved" or "missed").."  •  argument "..argumentScore.." / 4",390,344,fonts.tiny,colors.ink)
  divider(390,386,778)
  text("THE RULING",390,407,fonts.tiny,colors.red)
  local ruling=current.outcome
  if current.merit=="suppress" and not good then ruling="MOTION DENIED ON THIS RECORD. Strengthen the factual link, witness challenge, and requested remedy before seeking suppression. "..current.doctrine.." may support a renewed motion on a better-developed record."
  elseif current.merit=="deny" and not good then ruling="EVIDENCE ADMITTED. The record supports this search under the governing rule; test the details and acknowledge the doctrine's limits."
  end
  text(ruling,390,435,fonts.body,colors.ink,"left",740)
  text("PRECEDENT  ·  "..current.doctrine,390,560,fonts.tiny,colors.blue,"left",740)
  rounded(657,648,250,48,7,colors.navy); text(casePos==#caseOrder and "FINAL SCORE  →" or "NEXT CASE  →",671,661,fonts.tiny,colors.gold,"center",222)
end
local function drawResults()
  drawBackdrop("intro"); drawCharacter("counsel-shout",28,100,442,594,.92); drawCharacter("prosecutor-surprised",810,91,420,600,.9)
  panel(322,105,636,502,16,colors.paper,{.67,.58,.43})
  rounded(322,105,636,6,4,colors.gold)
  text("TRIAL COMPLETE",352,123,fonts.head,colors.ink,"center",576)
  text("YOUR FINAL SCORE",352,229,fonts.small,colors.blue,"center",576)
  text(score.."  /  "..runMaxScore,352,272,fonts.huge,colors.ink,"center",576)
  local rank=score>=math.ceil(runMaxScore*.9) and "ACE COUNSEL" or (score>=math.ceil(runMaxScore*.7) and "SHARP ADVOCATE" or (score>=math.ceil(runMaxScore*.45) and "COUNSEL IN TRAINING" or "BACK TO THE BOOKS"))
  text(rank,352,380,fonts.head,colors.red,"center",576)
  divider(395,429,490)
  text("Every case can turn on one small fact. Review the doctrine,\nquestion the search, and keep the remedy precise.",384,442,fonts.small,colors.ink,"center",512)
  text(runMode=="daily" and ("DAILY DOCKET  /  "..dailyLabel) or (runMode=="practice" and "SINGLE CASE PRACTICE" or "QUESTION AND ANSWER ORDER SHUFFLED EACH DOCKET"),352,501,fonts.tiny,colors.blue,"center",576)
  rounded(482,536,316,53,7,colors.navy); text("BACK TO MAIN MENU",482,551,fonts.tiny,colors.gold,"center",316)
  center("Enter or click to continue  ·  Escape returns",624,fonts.tiny,colors.cream)
end
local function draw()
  love.graphics.push(); love.graphics.translate(ox,oy); love.graphics.scale(scale)
  if screen=="title" then drawTitle() elseif screen=="learn" then drawLearn() elseif screen=="intro" then drawIntro() elseif screen=="investigation" then drawInvestigation() elseif screen=="cross" then drawCross() elseif screen=="argument" then drawArgument() elseif screen=="practice" then drawPractice() elseif screen=="notebook" then drawNotebook() elseif screen=="play" then drawCourt() elseif screen=="ruling" then drawRuling() else drawResults() end
  love.graphics.pop()
end
local function advance()
  if screen=="intro" then startCase()
  elseif screen=="investigation" then evidenceViewed[evidenceTab]=true
  elseif screen=="cross" then
    if not crossAnswered then
      crossAnswered=true; crossCorrect=crossSelected==current.crossEvidence
      if crossCorrect then score=score+1; crossFeedback="Exhibit admitted. You tested the witness's account against the record."
      else crossFeedback="This exhibit does not establish the point you need. Reconsider what the record actually shows." end
    else beginQuestions() end
  elseif screen=="argument" then submitArgument(argumentChoice)
  elseif screen=="play" then finishAnswer(selected)
  elseif screen=="ruling" then nextAfterRuling()
  elseif screen=="results" then beginGame() end
end
function love.load()
  love.graphics.setDefaultFilter("linear","linear",1); love.math.setRandomSeed(os.time()); loadFonts(); loadArt()
  local w,h=love.graphics.getDimensions(); love.resize(w,h)
end
function love.resize(w,h)
  scale=math.min(w/W,h/H); ox=(w-W*scale)/2; oy=(h-H*scale)/2
end
function love.update(dt) animTime=animTime+math.min(dt,.05) end
function love.draw() draw() end
function love.keypressed(key)
  if key=="escape" then screen="title"; return end
  if screen=="title" then
    if key=="d" then difficultyMode=difficultyMode%3+1
    elseif key=="1" then beginGame()
    elseif key=="2" then beginDaily()
    elseif key=="3" then screen="practice"
    elseif key=="4" then screen="notebook"
    elseif key=="5" then screen="learn"; learnScroll=0
    elseif key=="return" or key=="space" then beginGame() end
  elseif screen=="learn" then
    if key=="down" or key=="pagedown" then learnScroll=math.min(LEARN_MAX_SCROLL,learnScroll+(key=="pagedown" and 360 or 72))
    elseif key=="up" or key=="pageup" then learnScroll=math.max(0,learnScroll-(key=="pageup" and 360 or 72))
    elseif key=="home" then learnScroll=0
    elseif key=="end" then learnScroll=LEARN_MAX_SCROLL end
  elseif screen=="intro" or screen=="ruling" then
    if key=="return" or key=="space" or key=="right" then advance() end
  elseif screen=="investigation" then
    if key=="left" then evidenceViewed[evidenceTab]=true; evidenceTab=(evidenceTab+1)%3+1
    elseif key=="right" then evidenceViewed[evidenceTab]=true; evidenceTab=evidenceTab%3+1
    elseif key=="return" or key=="space" then evidenceViewed[evidenceTab]=true
      if evidenceViewed[1] and evidenceViewed[2] and evidenceViewed[3] then screen="cross" end
    end
  elseif screen=="cross" then
    if key=="1" then crossSelected=1; advance()
    elseif key=="2" then crossSelected=2; advance()
    elseif key=="3" then crossSelected=3; advance()
    elseif key=="up" or key=="left" then crossSelected=(crossSelected+1)%3+1
    elseif key=="down" or key=="right" then crossSelected=crossSelected%3+1
    elseif key=="return" or key=="space" then advance() end
  elseif screen=="argument" then
    if not argumentAnswered then
      if key=="1" or key=="kp1" then argumentChoice=1; submitArgument(1)
      elseif key=="2" or key=="kp2" then argumentChoice=2; submitArgument(2)
      elseif key=="3" or key=="kp3" then argumentChoice=3; submitArgument(3)
      elseif key=="up" then argumentChoice=(argumentChoice+1)%3+1
      elseif key=="down" then argumentChoice=argumentChoice%3+1
      elseif key=="return" or key=="space" then submitArgument(argumentChoice) end
    elseif key=="return" or key=="space" or key=="right" then submitArgument(argumentChoice) end
  elseif screen=="practice" then
    if key=="left" then practiceIndex=(practiceIndex-2)%#CASES+1
    elseif key=="right" then practiceIndex=practiceIndex%#CASES+1
    elseif key=="up" then practiceIndex=(practiceIndex-4)%#CASES+1
    elseif key=="down" then practiceIndex=(practiceIndex+2)%#CASES+1
    elseif key=="return" or key=="space" then beginPractice(practiceIndex) end
  elseif screen=="notebook" then
    if key=="up" then notebookIndex=(notebookIndex-2)%#CASES+1
    elseif key=="down" then notebookIndex=notebookIndex%#CASES+1
    elseif key=="return" or key=="space" then beginPractice(notebookIndex) end
  elseif screen=="play" then
    if key=="h" and not answered and difficultyMode~=3 then hintVisible=not hintVisible; hintUsed=hintVisible or hintUsed
    elseif not answered then
      if key=="1" or key=="kp1" then selected=1; finishAnswer(1)
      elseif key=="2" or key=="kp2" then selected=2; finishAnswer(2)
      elseif key=="3" or key=="kp3" then selected=3; finishAnswer(3)
      elseif key=="up" then selected=(selected+1)%3+1
      elseif key=="down" then selected=selected%3+1
      elseif key=="return" or key=="space" then finishAnswer(selected) end
    elseif key=="return" or key=="space" or key=="right" then advance() end
  elseif screen=="results" and (key=="return" or key=="space") then
    if runMode=="practice" then screen="practice" else screen="title" end
  end
end
function love.mousepressed(mx,my,button)
  if button~=1 then return end
  local x,y=(mx-ox)/scale,(my-oy)/scale
  if screen=="title" then
    for i=1,5 do local yy=313+(i-1)*49; if x>=397 and x<=883 and y>=yy and y<=yy+43 then
        if i==1 then beginGame() elseif i==2 then beginDaily() elseif i==3 then screen="practice" elseif i==4 then screen="notebook" else screen="learn"; learnScroll=0 end
        return
    end end
    if x>=500 and x<=780 and y>=572 and y<=607 then difficultyMode=difficultyMode%3+1 end
  elseif screen=="learn" then
    if x>=1040 and x<=1178 and y>=622 and y<=652 then screen="title"
    elseif x>=92 and x<=1180 and y>=LEARN_VIEW_Y and y<=LEARN_VIEW_Y+LEARN_VIEW_H then
      if y<LEARN_VIEW_Y+36 then learnScroll=math.max(0,learnScroll-120)
      elseif y>LEARN_VIEW_Y+LEARN_VIEW_H-36 then learnScroll=math.min(LEARN_MAX_SCROLL,learnScroll+120) end
    end
  elseif screen=="intro" then startCase()
  elseif screen=="investigation" then
    for i=1,3 do local tx=114+(i-1)*350; if x>=tx and x<=tx+322 and y>=207 and y<=261 then evidenceViewed[i]=true; evidenceTab=i; return end end
    if x>=114 and x<=364 and y>=574 and y<=617 then evidenceViewed[evidenceTab]=true; evidenceTab=(evidenceTab+1)%3+1
    elseif x>=382 and x<=632 and y>=574 and y<=617 then evidenceViewed[evidenceTab]=true; evidenceTab=evidenceTab%3+1
    elseif x>=847 and x<=1134 and y>=574 and y<=617 and evidenceViewed[1] and evidenceViewed[2] and evidenceViewed[3] then screen="cross" end
  elseif screen=="cross" then
    if crossAnswered then if x>=901 and x<=1172 and y>=626 and y<=674 then beginQuestions() end
    else for i=1,3 do local yy=381+(i-1)*55; if x>=358 and x<=1172 and y>=yy and y<=yy+45 then crossSelected=i; advance(); return end end end
  elseif screen=="argument" then
    if argumentAnswered then if x>=880 and x<=1124 and y>=553 and y<=596 then submitArgument(argumentChoice) end
    else for i=1,3 do local yy=258+(i-1)*75; if x>=154 and x<=1124 and y>=yy and y<=yy+61 then argumentChoice=i; submitArgument(i); return end end end
  elseif screen=="practice" then
    for i=1,#CASES do local col=(i-1)%3; local row=math.floor((i-1)/3); local bx=120+col*350; local by=205+row*96
      if x>=bx and x<=bx+320 and y>=by and y<=by+78 then practiceIndex=i; beginPractice(i); return end end
    if x>=472 and x<=808 and y>=564 and y<=612 then beginPractice(practiceIndex) end
  elseif screen=="notebook" then
    if x>=92 and x<=439 and y>=201 and y<576 then notebookIndex=math.max(1,math.min(#CASES,math.floor((y-202)/31)+1))
    elseif x>=942 and x<=1177 and y>=590 and y<=633 then beginPractice(notebookIndex) end
  elseif screen=="ruling" then
    if x>=657 and x<=907 and y>=648 and y<=696 then nextAfterRuling() end
  elseif screen=="results" then
    if x>=482 and x<=798 and y>=536 and y<=589 then if runMode=="practice" then screen="practice" else screen="title" end end
  elseif screen=="play" then
    if answered then
      if x>=1080 and x<=1246 and y>=17 and y<=60 then finishAnswer(selected) end
    else for i=1,3 do local ax,ay,aw,ah=answerRect(i); if x>=ax and x<=ax+aw and y>=ay and y<=ay+ah then finishAnswer(i); return end end end
  end
end
function love.wheelmoved(_,y)
  if screen=="learn" then learnScroll=math.max(0,math.min(LEARN_MAX_SCROLL,learnScroll-y*84)) end
end
