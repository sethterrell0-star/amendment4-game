// Fourth Counsel — all case state, choices, and scoring live in WebAssembly.
typedef unsigned int u32;

typedef struct {
  const char *title, *badge, *setting, *facts, *evidence, *doctrine;
  const char *prompt[3];
  const char *choice[3][3];
  const char *feedback[3][3];
  int best[3];
} Case;

static const Case cases[] = {
 {"The Midnight Knock","HOME • CONSENT","A quiet block after midnight",
  "At 12:14 a.m., officers knock on Mara Vale’s door. They have no warrant. She opens it a few inches and says, “I don’t want you inside.” Her adult roommate, Eli, walks up behind her and says, “Come in, you can look around.” Officers enter and find a stolen laptop in a shared living room.",
  "Laptop found in shared living room","Georgia v. Randolph · shared-home consent",
  {"Officer Reyes says Eli “invited us in.” What do you establish first?","What rule should the judge apply to the entry?","Choose your motion."},
  {{"Mara was physically present and expressly refused entry.","Eli paid more rent, so his permission controls.","The officers never showed Mara a warrant."},
   {"An occupant’s consent always overrides another occupant.","A physically present co-occupant’s express refusal can defeat another occupant’s consent.","Roommates have no privacy in common areas."},
   {"Move to suppress: the entry violated Randolph’s rule.","Move to suppress because the officers failed to read Miranda rights.","Ask the court to ignore the entry because the laptop was in plain view."}},
  {{"Strong foundation: her presence and direct refusal are the key facts under Randolph.","Who pays more rent is not the constitutional test.","A warrant matters, but the immediate dispute is conflicting occupant consent."},
   {"Consent is not unlimited, but the categorical claim misses Randolph’s present-objector rule.","Correct. Randolph generally bars warrantless entry when a physically present resident expressly refuses, despite a co-occupant’s consent.","Shared space does not erase each resident’s Fourth Amendment interests."},
   {"Correct theory. On these facts, the express refusal makes the roommate’s invitation insufficient.","Miranda concerns custodial interrogation, not entry into a home.","Plain view does not cure an unlawful entry."}}, {0,1,0}},
 {"Pocket-Sized Search","TRAFFIC • DIGITAL PRIVACY","A roadside stop in the rain",
  "After a valid arrest for driving with a suspended license, an officer finds a smartphone in Devon’s pocket. Without seeking a warrant, she scrolls through messages and photos. She finds a thread about a recent robbery. There is no emergency and no attempt to remotely wipe the device.",
  "Messages and photos copied from phone","Riley v. California · digital data incident to arrest",
  {"What is the most important distinction in this search?","Which precedent gives you the rule?","Frame the request for relief."},
  {{"A phone is physical evidence and may always be searched after arrest.","The arrest may be valid, but digital contents raise a separate privacy question.","The officer needed probable cause to arrest Devon."},
   {"Riley v. California generally requires a warrant to search phone contents.","Terry v. Ohio allows any search after a traffic stop.","Carpenter v. United States controls every search of a phone."},
   {"Suppress the phone’s digital contents; the arrest itself can remain valid.","Suppress every item found during the arrest, including the phone itself.","Exclude the evidence because Devon was not read his rights first."}},
  {{"A valid arrest permits a limited search of the person, not an automatic review of digital data.","Correct. Separate the lawful arrest from the warrantless search of the phone’s contents.","The scenario states the arrest was valid; focus on the later phone search."},
   {"Correct. Riley recognizes the substantial privacy interests in modern phones and generally requires a warrant for their contents.","Terry is a stop-and-frisk case, not a blanket post-arrest phone-search rule.","Carpenter concerns historical cell-site location information, not every phone search."},
   {"Correct and tailored: Riley targets the digital contents, absent an applicable exigency.","The physical phone may be seized incident to arrest; its contents are different.","Miranda is about statements during custodial interrogation."}}, {1,0,0}},
 {"The Apartment Signal","LOCATION • WARRANT","A month of quiet pings",
  "Investigators obtain 30 days of historical cell-site location information for Niko’s phone from his carrier. They have no warrant. The records place Niko near a series of warehouse break-ins. Police use the data to get a warrant for his apartment, where they find stolen watches.",
  "Thirty days of historical cell-site location data","Carpenter v. United States · historical CSLI",
  {"What makes these records different from an ordinary business record?","What is the governing constitutional rule?","What is the most precise challenge to the watches?"},
  {{"They reveal a detailed record of a person’s movements over time.","The carrier owns the towers, so the records can never be private.","Niko had to turn his phone off if he wanted privacy."},
   {"The third-party doctrine always eliminates privacy in carrier records.","The government generally needs a warrant for extended historical CSLI.","A warrant is needed only if officers physically enter the carrier’s office."},
   {"Challenge the CSLI collection and argue the apartment warrant relied on its fruits.","Ask to suppress the watches because all digital evidence is inadmissible.","Argue that Carpenter bans real-time tracking in every emergency."}},
  {{"Correct. The depth, breadth, and retrospective nature of the location record matter.","Carpenter limits a simplistic application of the third-party doctrine to extended CSLI.","A person does not automatically surrender all privacy by carrying a phone."},
   {"Carpenter rejects a categorical third-party-doctrine answer for this type of extended CSLI.","Correct. Carpenter generally requires a warrant supported by probable cause to obtain extended historical CSLI, subject to case-specific exceptions.","The constitutional question is access to the records, not officers’ physical entry into carrier property."},
   {"Correct. If the warrant affidavit depends on unlawfully obtained CSLI, challenge the downstream search under the exclusionary rule.","There is no blanket ban on digital evidence; identify the unlawful acquisition and its causal link.","Carpenter addresses historical CSLI and does not categorically resolve every real-time tracking emergency."}}, {0,1,0}},
 {"The Bus Stop Patdown","STREET • REASONABLE SUSPICION","A crowded station at dusk",
  "An officer sees Jules step off a bus and look around nervously. Jules wears a bulky jacket. The officer has no report of a crime and sees no weapon-like movement. He stops Jules and pats down every pocket, finding a small bag of pills.",
  "Pills found during a full pocket search","Terry v. Ohio · stop and protective frisk",
  {"Which facts matter to whether the stop was justified?","What limits a protective frisk?","How do you attack the pills?"},
  {{"Nervousness and a bulky jacket, by themselves, prove a crime.","The officer needs specific, articulable facts supporting reasonable suspicion of crime.","A bus station is a place where anyone may be searched."},
   {"A frisk may search every pocket for evidence once a stop occurs.","A frisk is limited to a weapons check when the officer reasonably suspects the person is armed and dangerous.","Terry requires probable cause for every brief stop."},
   {"Move to suppress: neither the stop nor the evidentiary pocket search is justified here.","Argue only that the pills were not in plain view.","Ask for suppression because officers must always obtain warrants in public."}},
  {{"Correct. Reasonable suspicion must rest on particularized, objective facts; vague nervousness and clothing alone are weak.","Correct. Terry requires specific, articulable facts, not a hunch.","Public places remain protected by the Fourth Amendment."},
   {"A stop does not automatically authorize a full evidence search.","Correct. A frisk is a limited pat-down for weapons, based on reasonable suspicion the person is armed and dangerous.","Terry allows brief stops on reasonable suspicion; probable cause is not always required."},
   {"Correct. Challenge both the unsupported stop and the frisk that exceeded its protective purpose.","Plain view does not address how the pills were discovered inside a pocket.","Public searches can be lawful under exceptions; the warrant question is not categorical."}}, {1,1,0}},
 {"The Specific Warrant","HOME • WARRANT SCOPE","A search with clear boundaries",
  "After finding probable cause, a neutral judge signs a warrant naming Apartment 4B and a stolen camera with its serial number. Officers execute it at the listed address, knock and announce, then look in a kitchen drawer large enough to hold the camera. Inside they find the camera with the matching serial number. They do not search anywhere beyond the warrant’s scope.",
  "Camera found inside the place and scope named by warrant","Fourth Amendment · probable cause · particularity · scope",
  {"What parts of the warrant and its execution matter most?","Was searching the drawer within the warrant’s scope?","What should you tell the judge?"},
  {{"A neutral judge approved a particular address and a particular stolen camera.","The warrant is invalid because police have to announce every item they seek.","Any warrant lets police search the entire building."},
   {"Yes. A camera can fit in the drawer, and the warrant named it.","No. Officers may search only rooms, never drawers.","No. Once the camera is located, officers may keep searching for unrelated evidence."},
   {"Concede the search was authorized and focus on any independent defense.","Move to suppress because the officers should have searched without a warrant.","Argue that a matching camera is automatically excluded as fruit of the warrant."}},
  {{"Correct. The warrant is supported by probable cause, identifies the apartment and item, and officers stick to its limits.","The Fourth Amendment does not require a warrant to list every movement or step during execution.","The warrant here is specific to Apartment 4B, not the whole building."},
   {"Correct. Officers may search places where the described object could reasonably be found.","Containers that can hold the object may be within the warrant’s scope.","The facts say the camera was the listed item; unrelated evidence is not the basis for the search."},
  {"Correct. On these facts, the warrant is valid and the camera was found within its authorized scope, so there is no Fourth Amendment basis to suppress it.","A warrant is the reason the search is authorized on this record.","Evidence obtained within a valid warrant is not automatically fruit of the poisonous tree."}}, {0,0,0}},
 {"The Extra Twelve Minutes","TRAFFIC • DETENTION","A traffic stop that would not end",
  "An officer stops Ren for a broken tail light. She issues a warning, returns Ren’s license and papers, and says Ren is free to go. With no new facts suggesting a crime, she orders Ren to wait twelve minutes while a drug dog arrives. The dog alerts and officers search the car.",
  "Evidence found after the dog sniff","Rodriguez v. United States · traffic-stop duration",
  {"When did the traffic mission end?","What additional justification was needed to keep Ren there?","What is the best suppression argument?"},
  {{"When the officer finished the warning and returned Ren’s papers.","A traffic stop ends only after the driver reaches home.","The stop never ends once a dog is called."},
   {"No additional suspicion was needed because the stop was lawful at first.","Reasonable suspicion of another crime was needed to extend the stop beyond its traffic mission.","Probable cause to search the car was automatic after any traffic violation."},
   {"Move to suppress: the dog sniff unlawfully prolonged the stop, and the alert followed that detention.","Argue the officer could not issue a warning for a tail light.","Argue that dog sniffs always violate the Fourth Amendment."}},
  {{"Correct. The mission was complete when the warning was issued and Ren’s documents were returned.","An ordinary traffic stop is a seizure; its length is not measured by the driver’s trip home.","Calling a dog does not extend the original stop by itself."},
   {"The officer needs no extra reason to finish the original traffic tasks, but she cannot add time for a dog sniff without reasonable suspicion.","Correct. Under Rodriguez, a traffic stop may not be extended for a dog sniff absent reasonable suspicion of criminal activity.","A traffic violation does not automatically create probable cause to search for unrelated evidence."},
   {"Correct. The added detention produced the dog alert, so challenge the prolongation and resulting search.","The traffic warning itself is not the constitutional problem described here.","Dog sniffs are not categorically unconstitutional; the added detention is the issue."}}, {0,1,0}},
 {"Canvas in the Trunk","VEHICLE • PROBABLE CAUSE","A credible report and a road-side stop",
  "A reliable witness gives police specific, recently verified details that a stolen painting is inside a blue van, including its route and a distinctive frame. Officers stop the van on the highway, confirm the details through the window, and have probable cause to believe the painting is in the trunk. Without a warrant, they open a portfolio large enough to hold it and find the painting.",
  "Painting found inside a container in the van","Carroll v. United States · automobile exception · scope",
  {"What facts support the search?","How far does probable cause to search for the painting reach?","What should you ask the court to do?"},
  {{"The specific, reliable information and officers’ confirmation create probable cause.","A vague anonymous tip always authorizes a vehicle search.","A vehicle can never be searched without a warrant."},
   {"It reaches places and containers in the van where the painting could fit.","Probable cause to search a car permits opening every container, regardless of size.","It permits only a visual look through the windows."},
   {"Concede suppression is unwarranted: the automobile exception covers this probable-cause search and its scope.","Move to suppress because police always need a warrant for a car.","Ask to suppress because the officers searched a container, even though the painting could fit."}},
  {{"Correct. Particularized, corroborated facts supply probable cause in this fictional record.","An unverified vague tip alone would not automatically establish probable cause.","The automobile exception allows certain vehicle searches on probable cause."},
   {"Correct. The search may reach every part of the vehicle and containers that could conceal the object of the search.","The search scope tracks the object sought; size still matters.","The automobile exception allows more than looking through windows when probable cause exists."},
   {"Correct. With probable cause and a container capable of holding the painting, the vehicle exception authorizes the search described.","A warrantless vehicle search can be valid under the automobile exception.","A container can be searched when it could hold the sought object."}}, {0,0,0}},
 {"The Wrong Door","WARRANT • PARTICULARITY","A number off on the warrant",
  "A valid warrant names 44 Pine Street, Apartment 4B, and stolen watches. The building has identical neighboring units. Officers’ paperwork and the door placard both say 4D, but they force open 4D’s door and search it for the watches. The resident of 4D has no connection to the investigation.",
  "Items found inside the wrong apartment","Maryland v. Garrison · warrant particularity · objectively reasonable execution",
  {"Which detail changes the execution analysis?","Can the officers rely on a reasonable mistake here?","What is the strongest motion?"},
  {{"Both their paperwork and the door placard clearly said 4D, not the authorized 4B.","The apartments look alike, so the warrant automatically covers every unit.","A search warrant does not have to identify the place to be searched."},
   {"Yes. Officers may rely on any mistaken description, even after discovering it.","No. The clear address information gave them no objectively reasonable basis to think 4D was 4B.","Yes. Any valid warrant for the building permits a search of all apartments."},
   {"Move to suppress: they knowingly searched a unit the warrant did not authorize.","Ask to suppress because warrants can never cover apartments.","Argue the watches were in plain view, which cures the wrong-door entry."}},
  {{"Correct. The written address and visible placard both identify 4D, while the warrant is for 4B.","Similar layouts do not expand the warrant to all units.","The warrant must particularly describe the place to be searched."},
   {"Garrison allows reasonable mistakes while executing a warrant, but the stipulated facts make this mistake unreasonable.","Correct. The clear mismatch defeats an objectively reasonable belief that 4D was the authorized unit.","A building warrant does not automatically extend to every separate apartment."},
   {"Correct. The warrant names another apartment, and no reasonable execution mistake excuses this entry on the stated facts.","A warrant may authorize a search of a particular apartment when sufficiently described.","Plain view does not retroactively make an unauthorized entry lawful."}}, {0,1,0}}
};

#define N (sizeof(cases)/sizeof(cases[0]))
static int active=-1, stage=0, score=0, total=0, done=0, lastChoice=-1, lastStage=0, casePos=0, roundScore=0, roundTotal=0;
static unsigned int order[N];
static unsigned int seed=0xA341316C;
static unsigned int randn(void){seed^=seed<<13;seed^=seed>>17;seed^=seed<<5;return seed;}
static void shuffle(void){for(int i=0;i<(int)N;i++)order[i]=(unsigned int)i;for(int i=(int)N-1;i>0;i--){int j=randn()%(i+1);unsigned int t=order[i];order[i]=order[j];order[j]=t;}}
__attribute__((export_name("start_round"))) void start_round(unsigned int s){seed=s?s:0xA341316C;shuffle();active=-1;stage=0;score=0;total=0;done=0;lastChoice=-1;lastStage=0;casePos=0;roundScore=0;roundTotal=0;}
__attribute__((export_name("start_case"))) void start_case(unsigned int id){casePos=id;active=order[id%N];stage=0;score=0;total=0;done=0;lastChoice=-1;lastStage=0;}
__attribute__((export_name("choose"))) void choose(int c){if(active<0||done||c<0||c>2)return;lastChoice=c;lastStage=stage;total++;roundTotal++;if(c==cases[active].best[stage]){score++;roundScore++;}if(stage<2)stage++;else done=1;}
__attribute__((export_name("get_count"))) int get_count(void){return (int)N;}
__attribute__((export_name("get_order"))) int get_order(int i){return order[i%(int)N];}
__attribute__((export_name("get_active"))) int get_active(void){return active;}
__attribute__((export_name("get_stage"))) int get_stage(void){return stage;}
__attribute__((export_name("get_score"))) int get_score(void){return score;}
__attribute__((export_name("get_total"))) int get_total(void){return total;}
__attribute__((export_name("get_done"))) int get_done(void){return done;}
__attribute__((export_name("get_last"))) int get_last(void){return lastChoice;}
__attribute__((export_name("get_last_stage"))) int get_last_stage(void){return lastStage;}
__attribute__((export_name("get_case_pos"))) int get_case_pos(void){return casePos;}
__attribute__((export_name("get_round_score"))) int get_round_score(void){return roundScore;}
__attribute__((export_name("get_round_total"))) int get_round_total(void){return roundTotal;}
__attribute__((export_name("get_case_title"))) const char *get_case_title(int i){return cases[order[i%(int)N]].title;}
__attribute__((export_name("get_perfect"))) int get_perfect(void){return active>=0&&total==3&&score==3;}
__attribute__((export_name("get_title"))) const char *get_title(void){return active<0?"":cases[active].title;}
__attribute__((export_name("get_badge"))) const char *get_badge(void){return active<0?"":cases[active].badge;}
__attribute__((export_name("get_setting"))) const char *get_setting(void){return active<0?"":cases[active].setting;}
__attribute__((export_name("get_facts"))) const char *get_facts(void){return active<0?"":cases[active].facts;}
__attribute__((export_name("get_evidence"))) const char *get_evidence(void){return active<0?"":cases[active].evidence;}
__attribute__((export_name("get_doctrine"))) const char *get_doctrine(void){return active<0?"":cases[active].doctrine;}
__attribute__((export_name("get_prompt"))) const char *get_prompt(void){return active<0||done?"":cases[active].prompt[stage];}
__attribute__((export_name("get_choice"))) const char *get_choice(int i){return active<0?"":cases[active].choice[stage][i%3];}
__attribute__((export_name("get_feedback"))) const char *get_feedback(void){return active<0||lastChoice<0?"":cases[active].feedback[lastStage][lastChoice];}
__attribute__((export_name("get_result_title"))) const char *get_result_title(void){if(score==3)return "Exceptional advocacy.";if(score==2)return "A strong argument. One point needs a closer read.";if(score==1)return "The record needs a tighter theory.";return "Back to the case law.";}
__attribute__((export_name("get_outcome"))) const char *get_outcome(void){switch(active){case 0:return "RULING: SUPPRESS THE LAPTOP. The physically present resident expressly refused entry.";case 1:return "RULING: SUPPRESS THE PHONE CONTENTS. Riley generally requires a warrant.";case 2:return "RULING: SUPPRESS THE WATCHES IF THE APARTMENT WARRANT DEPENDED ON THE UNLAWFUL LOCATION RECORDS.";case 3:return "RULING: SUPPRESS THE PILLS. The stop lacks specific facts and the frisk exceeded its protective scope.";case 4:return "RULING: MOTION DENIED. Officers used a valid, particular warrant and stayed within its scope.";case 5:return "RULING: SUPPRESS THE EVIDENCE THAT FOLLOWED THE UNLAWFUL EXTENSION OF THE TRAFFIC STOP.";case 6:return "RULING: MOTION DENIED. Probable cause supported the vehicle search and the portfolio could hold the painting.";case 7:return "RULING: SUPPRESS EVIDENCE FOUND IN APARTMENT 4D. It was outside the warrant’s scope.";default:return "";}}
