local CASES = require("case_data")
local W, H = 1280, 720
local DIFFICULTIES = {"FOUNDATIONS", "APPLICATION", "ADVANCED", "EXPERT"}
local TOTAL_QUESTIONS = 0
for _, case in ipairs(CASES) do TOTAL_QUESTIONS = TOTAL_QUESTIONS + #case.questions end
local screen, caseOrder, casePos = "title", {}, 1
local stagePos, score, answered, selected = 1, 0, false, 1
local feedback, feedbackGood, caseCorrect = "", false, 0
local current, questionDeck, fonts, art, photos = nil, {}, {}, {}, {}
local runMode, difficultyMode, runMaxScore = "campaign", 2, TOTAL_QUESTIONS + #CASES
local hintUsed, hintVisible, crossAnswered, crossCorrect = false, false, false, false
local crossSelected, crossFeedback, evidenceTab, evidenceViewed, notebookIndex = 1, "", 1, {}, 1
local practiceIndex, dailyLabel = 1, ""
local argumentStep, argumentScore, argumentAnswered, argumentChoice = 1, 0, false, 1
local argumentMessage = ""
local animTime = 0
local scale, ox, oy = 1, 0, 0
local DIFFICULTY_NAMES = {"STUDY", "STANDARD", "EXPERT"}
local EVIDENCE_LABELS = {"CASE FILE", "ITEM AT ISSUE", "PRECEDENT"}
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
  for _,n in ipairs(names) do local ok,v=pcall(love.graphics.newImage,"assets/characters/custom/"..n..".png"); if ok then art[n]=v; v:setFilter("linear","linear") end end
  for _,n in ipairs({"courthouse","courtroom","police-car"}) do local ok,v=pcall(love.graphics.newImage,"assets/"..n..".jpg"); if ok then photos[n]=v; v:setFilter("linear","linear") end end
end
local function loadFonts()
  fonts.tiny=love.graphics.newFont(13); fonts.small=love.graphics.newFont(17); fonts.body=love.graphics.newFont(20)
  fonts.mid=love.graphics.newFont(26); fonts.head=love.graphics.newFont(38); fonts.big=love.graphics.newFont(62); fonts.huge=love.graphics.newFont(84)
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
  if feedbackGood then score=score+1; caseCorrect=caseCorrect+1 end
  if hintUsed and difficultyMode==2 and feedbackGood then score=math.max(0,score-1); caseCorrect=caseCorrect-1 end
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
  if art[name] then imageFit(art[name],x,y,w,h,alpha); return end
  -- Original layered box-character art: every layer is drawn in LÖVE so the
  -- cast stays crisp and can be recolored without external sprite files.
  local witness=name:find("witness")~=nil
  local counsel=name:find("counsel")~=nil
  local prosecutor=name:find("prosecutor")~=nil
  local palette = witness and {{.18,.42,.55},{.12,.29,.40},{.92,.67,.46},{.16,.12,.12}}
    or counsel and {{.18,.36,.78},{.10,.19,.43},{.91,.65,.45},{.12,.08,.07}}
    or {{.62,.16,.19},{.37,.08,.12},{.81,.53,.39},{.12,.08,.07}}
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
  -- Neck, block torso, tie and shirt are separate depth layers.
  box(cx-19*s,top+72*s,38*s,36*s,skin)
  box(cx-70*s,top+100*s,140*s,155*s,shade,8*s)
  box(cx-59*s,top+104*s,118*s,139*s,coat,6*s)
  box(cx-24*s,top+104*s,48*s,95*s,{.96,.93,.82})
  box(cx-8*s,top+108*s,16*s,91*s,prosecutor and colors.gold or colors.red,2*s)
  -- Detached hands: deliberately no arms.
  local gesture=angry and math.abs(math.sin(phase*1.7))*9*s or (surprised and math.sin(phase*1.3)*5*s or math.sin(phase)*2*s)
  local handY=top+149*s-gesture
  box(cx-91*s,handY,29*s,38*s,skin,8*s); box(cx+62*s,handY,29*s,38*s,skin,8*s)
  set({1,.81,.64},alpha or 1); love.graphics.rectangle("fill",cx-86*s,handY+5*s,5*s,21*s,2*s); love.graphics.rectangle("fill",cx+81*s,handY+5*s,5*s,21*s,2*s)
  -- Face base, shadow plane, cheeks, brows, eyes, nose and mouth.
  box(cx-48*s,top+8*s,96*s,79*s,skin,8*s)
  box(cx-43*s,top+57*s,86*s,24*s,{.70,.43,.32},5*s)
  box(cx-37*s,top+51*s,18*s,10*s,{.98,.76,.59},4*s); box(cx+19*s,top+51*s,18*s,10*s,{.98,.76,.59},4*s)
  box(cx-49*s,top-1*s,98*s,21*s,hair,5*s)
  box(cx-49*s,top+5*s,17*s,26*s,hair,3*s)
  local brow=angry and colors.red or hair
  box(cx-31*s,top+31*s,24*s,5*s,brow,2*s); box(cx+7*s,top+31*s,24*s,5*s,brow,2*s)
  local blink=math.abs(math.sin(animTime*1.1+x*.022))>.995
  local eyeH=surprised and 11 or (blink and 2 or 6)
  box(cx-27*s,top+39*s,13*s,eyeH,{.98,.98,.92},3*s); box(cx+14*s,top+39*s,13*s,eyeH,{.98,.98,.92},3*s)
  set(colors.ink,alpha or 1); love.graphics.circle("fill",cx-20*s,top+44*s,3.2*s); love.graphics.circle("fill",cx+21*s,top+44*s,3.2*s)
  box(cx-3*s,top+43*s,6*s,14*s,{.68,.40,.31},2*s)
  local mouthY=top+(surprised and 65 or 66)*s
  if surprised then set({.30,.05,.06},alpha or 1); love.graphics.ellipse("fill",cx,mouthY,8*s,11*s)
  elseif angry then set({.36,.04,.05},alpha or 1); love.graphics.ellipse("fill",cx,mouthY,12*s,(5+math.abs(math.sin(animTime*9+x)) * 4)*s)
  elseif doubtful then set({.34,.08,.09},alpha or 1); love.graphics.line(cx-11*s,mouthY+4*s,cx+11*s,mouthY-2*s)
  else set({.34,.08,.09},alpha or 1); love.graphics.line(cx-10*s,mouthY,cx+10*s,mouthY) end
  -- Lapel highlights provide a final foreground layer.
  set({.78,.84,1},(alpha or 1)*.78); love.graphics.polygon("fill",cx-57*s,top+112*s,cx-31*s,top+137*s,cx-46*s,top+167*s)
  set(colors.white,(alpha or 1)*.17); love.graphics.rectangle("fill",cx+42*s,top+108*s,8*s,130*s)
end
local function drawLogo(y)
  center("FOURTH",y,fonts.huge,colors.cream)
  center("COUNSEL",y+80,fonts.big,colors.gold)
  love.graphics.setLineWidth(6); set(colors.red); love.graphics.line(392,y+151,888,y+151)
  center("THE PEOPLE v. YOUR JUDGMENT",y+164,fonts.small,colors.white)
end
local function drawTitle()
  drawBackdrop("intro")
  drawCharacter("counsel-neutral",18,150,300,510,.96)
  drawCharacter("prosecutor-neutral",962,142,290,520,.94)
  drawLogo(55)
  rounded(408,279,464,39,9,colors.navy); text("CHOOSE YOUR DOCKET",408,287,fonts.small,colors.gold,"center",464)
  local entries={{"1  CAMPAIGN","Twelve escalating cases"},{"2  DAILY DOCKET","Same randomized docket worldwide"},{"3  PRACTICE","Choose a case and drill the rule"},{"4  DOCTRINE NOTEBOOK","Review cases, rules and outcomes"}}
  for i,e in ipairs(entries) do
    local yy=328+(i-1)*67
    rounded(399,yy,482,57,9,i==1 and colors.red or colors.paper)
    text(e[1],418,yy+6,fonts.small,i==1 and colors.white or colors.ink)
    text(e[2],418,yy+30,fonts.tiny,i==1 and colors.cream or colors.blue)
  end
  rounded(467,608,346,41,8,colors.gold)
  text("DIFFICULTY  /  "..DIFFICULTY_NAMES[difficultyMode].."   (D to change)",467,619,fonts.tiny,colors.navy,"center",346)
  center("1–4 select a mode • D changes difficulty • Esc returns here",674,fonts.tiny,colors.muted)
end
local function drawIntro()
  drawBackdrop("intro"); drawTop("LEVEL  "..casePos.." / "..#caseOrder.."  •  "..DIFFICULTIES[current.tier])
  drawCharacter("witness-one",24,108,330,492,.91)
  rounded(298,114,930,498,18,colors.paper)
  rounded(298,114,930,52,18,colors.red); love.graphics.rectangle("fill",298,140,930,26); text(current.tag,322,129,fonts.small,colors.white)
  text(current.title,332,187,fonts.head,colors.ink,"left",850)
  text(current.setting,334,235,fonts.small,colors.blue,"left",840)
  text("DIFFICULTY  /  "..DIFFICULTIES[current.tier],334,258,fonts.small,colors.red,"left",840)
  text("THE FACTS",334,278,fonts.small,colors.red)
  text(current.facts,334,305,fonts.body,colors.ink,"left",844)
  rounded(332,422,846,1,1,{.83,.84,.82})
  text("EVIDENCE AT ISSUE",334,440,fonts.small,colors.red)
  text(current.item,334,464,fonts.mid,colors.ink,"left",820)
  text(difficultyMode==3 and "EXPERT MODE  /  doctrine notes hidden" or "Doctrine: "..current.doctrine,334,520,fonts.small,colors.blue,"left",825)
  rounded(516,634,248,52,10,colors.gold); text("OPEN EVIDENCE DESK  →",516,646,fonts.tiny,colors.navy,"center",248)
  text("Enter / click to inspect the case file",18,674,fonts.tiny,colors.muted)
end

local function drawInvestigation()
  drawBackdrop("intro"); drawTop("INVESTIGATION  •  LEVEL "..casePos.." / "..#caseOrder)
  rounded(80,100,1120,550,18,colors.paper)
  text("THE EVIDENCE DESK",112,119,fonts.head,colors.ink)
  text("Inspect all three records. The witness will challenge your reading of the file.",114,168,fonts.small,colors.blue)
  for i,label in ipairs(EVIDENCE_LABELS) do
    local x=114+(i-1)*350
    rounded(x,211,322,56,9,evidenceTab==i and colors.red or colors.navy)
    text((evidenceViewed[i] and "✓  " or "")..label,x+8,228,fonts.small,colors.white,"center",306)
  end
  local labels={"OFFICIAL CASE FILE","PROPERTY / RECORD REVIEW","CONTROLLING PRECEDENT"}
  rounded(114,292,1020,258,12,{.91,.94,.95})
  text(labels[evidenceTab],140,312,fonts.small,colors.red)
  text(evidenceText(evidenceTab),142,350,fonts.mid,colors.ink,"left",950)
  rounded(114,574,250,43,9,colors.gold); text("←  PREVIOUS",114,586,fonts.tiny,colors.navy,"center",250)
  rounded(382,574,250,43,9,colors.gold); text("NEXT  →",382,586,fonts.tiny,colors.navy,"center",250)
  local ready=evidenceViewed[1] and evidenceViewed[2] and evidenceViewed[3]
  rounded(847,574,287,43,9,ready and colors.green or {.60,.64,.68})
  text(ready and "CALL THE WITNESS  →" or "REVIEW ALL THREE",847,586,fonts.tiny,colors.white,"center",287)
  center("← / → switch files  •  Enter marks this file reviewed",626,fonts.tiny,colors.blue)
end

local function drawCross()
  drawBackdrop("court"); drawTop("CROSS-EXAMINATION  •  PRESENT YOUR EXHIBIT")
  local witnessArt=current.witness or "witness-one"
  if crossAnswered then
    if crossCorrect then witnessArt=witnessArt..(witnessArt=="witness-one" and "-shocked" or "-angry")
    else witnessArt=witnessArt..(witnessArt=="witness-one" and "-doubt" or "-worry") end
  end
  drawCharacter(witnessArt,60,120,335,470,.98)
  rounded(324,112,894,482,16,colors.paper)
  rounded(324,112,894,58,14,colors.red); text("WITNESS: "..current.crossSpeaker,348,129,fonts.small,colors.white)
  text("TESTIMONY",358,198,fonts.small,colors.blue)
  text("“"..current.crossStatement.."”",358,231,fonts.mid,colors.ink,"left",808)
  text("Which exhibit best tests that statement?",358,347,fonts.small,colors.red)
  for i,label in ipairs(EVIDENCE_LABELS) do
    local yy=385+(i-1)*56
    local c=colors.white
    if crossAnswered and i==current.crossEvidence then c={.77,.97,.83} elseif crossAnswered and i==crossSelected then c={1,.80,.77} elseif not crossAnswered and i==crossSelected then c={.83,.91,1} end
    rounded(358,yy,814,47,8,c); text(i.."   "..label,377,yy+12,fonts.small,colors.ink,"left",770)
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
    argumentMessage=good and "Strong link. Your theory connects the record to the governing rule." or "This link does not fit the record. Review the marked answer and keep the remedy precise."
  end
end
local function drawArgument()
  drawBackdrop("court"); drawTop("BUILD YOUR MOTION  •  LINK THE ARGUMENT")
  local titles={"1  WHAT DID POLICE DO?","2  WHICH RULE CONTROLS?","3  WHY WAS IT LAWFUL OR UNLAWFUL?","4  WHAT RELIEF FITS?"}
  rounded(112,105,1056,510,18,colors.paper)
  text("ARGUMENT BUILDER",150,126,fonts.head,colors.ink)
  text(titles[argumentStep],154,191,fonts.mid,colors.red,"left",950)
  for i,label in ipairs(argumentChoices()) do
    local yy=259+(i-1)*77; local c=colors.white
    if argumentAnswered and i==argumentCorrectChoice() then c={.77,.97,.83} elseif argumentAnswered and i==argumentChoice then c={1,.80,.77} elseif not argumentAnswered and i==argumentChoice then c={.83,.91,1} end
    rounded(154,yy,970,64,9,c); text(i.."   "..label,177,yy+17,fonts.small,colors.ink,"left",925)
  end
  if argumentAnswered then text(argumentMessage,158,511,fonts.tiny,argumentChoice==argumentCorrectChoice() and colors.green or colors.red,"left",940) end
  rounded(880,553,244,43,9,colors.gold); text(argumentAnswered and "NEXT LINK  →" or "LOCK IN LINK  →",880,565,fonts.tiny,colors.navy,"center",244)
  center("1–3 choose • Enter confirms / advances",587,fonts.tiny,colors.blue)
end

local function drawPractice()
  drawBackdrop("intro"); drawTop("PRACTICE DOCKET")
  rounded(88,105,1104,535,18,colors.paper); text("Choose a case to rehearse",122,125,fonts.head,colors.ink)
  for i,c in ipairs(CASES) do
    local col=(i-1)%3; local row=math.floor((i-1)/3); local x=120+col*350; local y=205+row*96
    rounded(x,y,320,78,8,i==practiceIndex and colors.red or {.91,.94,.95})
    text(string.format("%02d  %s",i,c.title),x+13,y+11,fonts.tiny,i==practiceIndex and colors.white or colors.ink,"left",296)
    text(DIFFICULTIES[c.tier].."  •  "..c.tag,x+14,y+43,fonts.tiny,i==practiceIndex and colors.cream or colors.blue,"left",295)
  end
  rounded(472,564,336,48,9,colors.gold); text("START SELECTED CASE  →",472,578,fonts.small,colors.navy,"center",336)
  center("Arrow keys choose • Enter begins • Esc returns",622,fonts.tiny,colors.blue)
end

local function drawNotebook()
  drawBackdrop("intro"); drawTop("DOCTRINE NOTEBOOK")
  rounded(65,92,1150,560,18,colors.paper)
  text("FIELD GUIDE",95,108,fonts.head,colors.ink)
  local c=CASES[notebookIndex]
  text("CASES",100,171,fonts.small,colors.red)
  for i,entry in ipairs(CASES) do
    local yy=205+(i-1)*31
    local active=i==notebookIndex
    if active then rounded(92,yy-3,347,29,5,{.88,.91,.96}) end
    text(string.format("%02d  %s",i,entry.title),102,yy,fonts.tiny,active and colors.red or colors.ink,"left",325)
  end
  rounded(463,169,1,436,1,{.78,.81,.82})
  text(c.title,493,177,fonts.head,colors.ink,"left",675)
  text(c.doctrine,496,235,fonts.mid,colors.blue,"left",665)
  text("KEY FACTS",496,286,fonts.small,colors.red)
  text(c.facts,496,313,fonts.small,colors.ink,"left",654)
  text("EVIDENCE",496,424,fonts.small,colors.red)
  text(c.item,496,451,fonts.small,colors.ink,"left",654)
  text("PRACTICE RULING",496,491,fonts.small,colors.red)
  text(c.outcome,496,518,fonts.small,colors.ink,"left",654)
  rounded(942,590,235,43,8,colors.gold); text("PRACTICE THIS CASE",942,602,fonts.tiny,colors.navy,"center",235)
  text("↑ / ↓ browse • Enter practices",95,615,fonts.tiny,colors.blue)
end
local function answerRect(i) return 100, 458+(i-1)*59, 1080, 50 end
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
  rounded(72,365,1135,343,17,colors.paper)
  rounded(72,365,1135,52,16,colors.navy); love.graphics.rectangle("fill",72,398,1135,19)
  local stage=questionDeck[stagePos]
  text("THE COURT WANTS YOUR THEORY",98,399,fonts.small,colors.gold)
  text(stage.prompt,100,422,fonts.body,colors.ink,"left",1070)
  if hintVisible and difficultyMode~=3 then
    rounded(870,428,325,25,5,{.88,.94,1}); text("HINT: "..current.doctrine,881,432,fonts.tiny,colors.blue,"left",303)
  end
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
    rounded(1080,17,166,43,8,colors.gold); text(stagePos==#questionDeck and "SEE RULING →" or "CONTINUE →",1080,28,fonts.tiny,colors.navy,"center",166)
  else
    text(difficultyMode==3 and "Expert: hints disabled" or "Choose a response  •  H shows doctrine hint",101,667,fonts.tiny,colors.muted)
  end
end
local function drawRuling()
  drawBackdrop("court"); drawTop("THE COURT HAS RULED")
  local good=caseCorrect>=3 and crossCorrect and argumentScore>=3
  drawCharacter(good and "counsel-shout" or "counsel-surprised",8,104,455,590,.94)
  rounded(350,132,858,496,18,colors.paper)
  rounded(350,132,858,78,14,good and colors.green or colors.red)
  love.graphics.rectangle("fill",350,180,858,30)
  text(good and "PERFECT ARGUMENT!" or "CASE DECIDED",384,147,fonts.head,colors.white)
  text(current.title,390,231,fonts.mid,colors.ink,"left",770)
  text("YOUR PERFORMANCE",390,280,fonts.small,colors.blue)
  for i=1,#questionDeck do
    local x=392+(i-1)*71; rounded(x,319,54,14,7,i<=caseCorrect and colors.gold or {.79,.81,.81})
  end
  text(caseCorrect.." / "..#questionDeck.." calls  •  exhibit "..(crossCorrect and "proved" or "missed").."  •  argument "..argumentScore.." / 4",390,344,fonts.tiny,colors.ink)
  rounded(386,391,782,1,1,{.82,.83,.81})
  text("THE RULING",390,413,fonts.small,colors.red)
  local ruling=current.outcome
  if current.merit=="suppress" and not good then ruling="MOTION DENIED ON THIS RECORD. Strengthen the factual link, witness challenge, and requested remedy before seeking suppression. "..current.doctrine.." may support a renewed motion on a better-developed record."
  elseif current.merit=="deny" and not good then ruling="EVIDENCE ADMITTED. The record supports this search under the governing rule; test the details and acknowledge the doctrine's limits."
  end
  text(ruling,390,445,fonts.body,colors.ink,"left",740)
  text("RULE: "..current.doctrine,390,550,fonts.tiny,colors.blue,"left",740)
  rounded(657,648,250,48,9,colors.gold); text(casePos==#caseOrder and "FINAL SCORE →" or "NEXT CASE →",657,660,fonts.small,colors.navy,"center",250)
end
local function drawResults()
  drawBackdrop("intro"); drawCharacter("counsel-shout",28,100,442,594,.92); drawCharacter("prosecutor-surprised",810,91,420,600,.9)
  rounded(322,105,636,502,20,colors.paper)
  rounded(322,105,636,92,18,colors.red); love.graphics.rectangle("fill",322,167,636,30)
  text("TRIAL COMPLETE",352,123,fonts.head,colors.white,"center",576)
  text("YOUR FINAL SCORE",352,229,fonts.small,colors.blue,"center",576)
  text(score.."  /  "..runMaxScore,352,272,fonts.huge,colors.ink,"center",576)
  local rank=score>=math.ceil(runMaxScore*.9) and "ACE COUNSEL" or (score>=math.ceil(runMaxScore*.7) and "SHARP ADVOCATE" or (score>=math.ceil(runMaxScore*.45) and "COUNSEL IN TRAINING" or "BACK TO THE BOOKS"))
  text(rank,352,380,fonts.head,colors.red,"center",576)
  text("Every case can turn on one small fact. Review the doctrine,\nquestion the search, and keep the remedy precise.",384,442,fonts.small,colors.ink,"center",512)
  text(runMode=="daily" and ("DAILY DOCKET  /  "..dailyLabel) or (runMode=="practice" and "SINGLE CASE PRACTICE" or "QUESTION AND ANSWER ORDER SHUFFLED EACH DOCKET"),352,501,fonts.tiny,colors.blue,"center",576)
  rounded(482,536,316,53,10,colors.gold); text("PLAY ANOTHER DOCKET",482,551,fonts.small,colors.navy,"center",316)
  center("Enter to play again     ·     Esc for title",624,fonts.tiny,colors.cream)
end
local function draw()
  love.graphics.push(); love.graphics.translate(ox,oy); love.graphics.scale(scale)
  if screen=="title" then drawTitle() elseif screen=="intro" then drawIntro() elseif screen=="investigation" then drawInvestigation() elseif screen=="cross" then drawCross() elseif screen=="argument" then drawArgument() elseif screen=="practice" then drawPractice() elseif screen=="notebook" then drawNotebook() elseif screen=="play" then drawCourt() elseif screen=="ruling" then drawRuling() else drawResults() end
  love.graphics.pop()
end
local function advance()
  if screen=="intro" then startCase()
  elseif screen=="investigation" then evidenceViewed[evidenceTab]=true
  elseif screen=="cross" then
    if not crossAnswered then
      crossAnswered=true; crossCorrect=crossSelected==current.crossEvidence
      if crossCorrect then score=score+1; crossFeedback="Exhibit admitted. You tested the witness's account against the record."
      else crossFeedback="This exhibit does not test the statement. The stronger exhibit is highlighted." end
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
    elseif key=="return" or key=="space" then beginGame() end
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
    if y>=328 and y<385 then beginGame()
    elseif y>=395 and y<452 then beginDaily()
    elseif y>=462 and y<519 then screen="practice"
    elseif y>=529 and y<586 then screen="notebook"
    elseif y>=608 and y<649 then difficultyMode=difficultyMode%3+1 end
  elseif screen=="intro" then startCase()
  elseif screen=="investigation" then
    for i=1,3 do local tx=114+(i-1)*350; if x>=tx and x<=tx+322 and y>=211 and y<=267 then evidenceViewed[i]=true; evidenceTab=i; return end end
    if x>=114 and x<=364 and y>=574 and y<=617 then evidenceViewed[evidenceTab]=true; evidenceTab=(evidenceTab+1)%3+1
    elseif x>=382 and x<=632 and y>=574 and y<=617 then evidenceViewed[evidenceTab]=true; evidenceTab=evidenceTab%3+1
    elseif x>=847 and x<=1134 and y>=574 and y<=617 and evidenceViewed[1] and evidenceViewed[2] and evidenceViewed[3] then screen="cross" end
  elseif screen=="cross" then
    if crossAnswered then if x>=901 and x<=1172 and y>=626 and y<=674 then beginQuestions() end
    else for i=1,3 do local yy=385+(i-1)*56; if x>=358 and x<=1172 and y>=yy and y<=yy+47 then crossSelected=i; advance(); return end end end
  elseif screen=="argument" then
    if argumentAnswered then if x>=880 and x<=1124 and y>=553 and y<=596 then submitArgument(argumentChoice) end
    else for i=1,3 do local yy=259+(i-1)*77; if x>=154 and x<=1124 and y>=yy and y<=yy+64 then argumentChoice=i; submitArgument(i); return end end end
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
