-- Fictional cases for Fourth Counsel. Each turn has one best answer and
-- a short explanation for every choice. This table is designed to be edited.
return {
  {
    title="The Midnight Knock", tag="HOME / CONSENT", setting="A quiet block after midnight",
    facts="At 12:14 a.m., officers knock on Mara Vale's door. They have no warrant. She opens it a few inches and says, ‘I don't want you inside.’ Her adult roommate, Eli, walks up behind her and says, ‘Come in, you can look around.’ Officers enter and find a stolen laptop in a shared living room.",
    item="Laptop found in shared living room", doctrine="Georgia v. Randolph · shared-home consent",
    witness="witness-one", outcome="SUPPRESS THE LAPTOP. Mara was present and expressly refused entry.",
    stages={
      {prompt="Officer Reyes says Eli ‘invited us in.’ What do you establish first?", correct=1, choices={
        {text="Mara was physically present and expressly refused entry.",why="Exactly. Her presence and direct refusal are the key facts under Randolph."},
        {text="Eli paid more rent, so his permission controls.",why="Who pays more rent is not the constitutional test."},
        {text="The officers never showed Mara a warrant.",why="A warrant matters, but the immediate dispute is conflicting occupant consent."}}},
      {prompt="What rule should the judge apply to the entry?", correct=2, choices={
        {text="An occupant's consent always overrides another occupant.",why="Consent is not unlimited, but that categorical claim misses Randolph's present-objector rule."},
        {text="A physically present co-occupant's express refusal can defeat another occupant's consent.",why="Correct. Randolph generally bars warrantless entry when a physically present resident expressly refuses, despite a co-occupant's consent."},
        {text="Roommates have no privacy in common areas.",why="Shared space does not erase each resident's Fourth Amendment interests."}}},
      {prompt="Choose your motion.", correct=1, choices={
        {text="Move to suppress: the entry violated Randolph's rule.",why="Correct theory. On these facts, the express refusal makes Eli's invitation insufficient."},
        {text="Move to suppress because police failed to read Miranda rights.",why="Miranda concerns custodial interrogation, not entry into a home."},
        {text="Ignore the entry because the laptop was in plain view.",why="Plain view does not cure an unlawful entry."}}},
    }
  },
  {
    title="Pocket-Sized Search", tag="TRAFFIC / DIGITAL PRIVACY", setting="A roadside stop in the rain",
    facts="After a valid arrest for driving with a suspended license, an officer finds a smartphone in Devon's pocket. Without a warrant, she scrolls through messages and photos. She finds a thread about a recent robbery. There is no emergency and no attempt to remotely wipe the device.",
    item="Messages and photos copied from phone", doctrine="Riley v. California · digital data incident to arrest",
    witness="witness-two", outcome="SUPPRESS THE PHONE CONTENTS. Riley generally requires a warrant to search phone data.",
    stages={
      {prompt="What is the most important distinction in this search?", correct=2, choices={
        {text="A phone is physical evidence and may always be searched after arrest.",why="A valid arrest permits a limited search of the person, not an automatic review of digital data."},
        {text="The officer needed probable cause to arrest Devon.",why="The scenario says the arrest was valid. Focus on the later phone search."},
        {text="The arrest may be valid, but digital contents raise a separate privacy question.",why="Correct. Separate the lawful arrest from the warrantless search of the phone's contents."}}},
      {prompt="Which precedent gives you the rule?", correct=1, choices={
        {text="Riley v. California generally requires a warrant to search phone contents.",why="Correct. Riley recognizes the substantial privacy interests in modern phones and generally requires a warrant for their contents."},
        {text="Terry v. Ohio allows any search after a traffic stop.",why="Terry is a stop-and-frisk case, not a blanket post-arrest phone-search rule."},
        {text="Carpenter controls every search of a phone.",why="Carpenter concerns historical cell-site location information, not every phone search."}}},
      {prompt="Frame the request for relief.", correct=1, choices={
        {text="Suppress the phone's digital contents; the arrest itself can remain valid.",why="Correct and tailored: Riley targets digital contents, absent an applicable exigency."},
        {text="Suppress every item found during the arrest, including the phone itself.",why="The physical phone may be seized incident to arrest; its contents are different."},
        {text="Exclude the evidence because Devon was not read his rights first.",why="Miranda is about statements during custodial interrogation."}}},
    }
  },
  {
    title="The Apartment Signal", tag="LOCATION / WARRANT", setting="A month of quiet pings",
    facts="Investigators obtain 30 days of historical cell-site location information for Niko's phone from his carrier. They have no warrant. The records place Niko near a series of warehouse break-ins. Police use the data to get a warrant for his apartment, where they find stolen watches.",
    item="Thirty days of historical cell-site location data", doctrine="Carpenter v. United States · historical CSLI",
    witness="witness-one", outcome="SUPPRESS THE WATCHES IF THE APARTMENT WARRANT DEPENDED ON THE UNLAWFUL LOCATION RECORDS.",
    stages={
      {prompt="What makes these records different from an ordinary business record?", correct=1, choices={
        {text="The carrier owns the towers, so its records can never be private.",why="Carpenter limits a simplistic application of the third-party doctrine to extended CSLI."},
        {text="They reveal a detailed record of a person's movements over time.",why="Correct. The depth, breadth, and retrospective nature of the location record matter."},
        {text="Niko had to turn his phone off if he wanted privacy.",why="A person does not automatically surrender all privacy by carrying a phone."}}},
      {prompt="What is the governing constitutional rule?", correct=2, choices={
        {text="The third-party doctrine always eliminates privacy in carrier records.",why="Carpenter rejects a categorical third-party-doctrine answer for extended CSLI."},
        {text="A warrant is needed only to enter the carrier's office.",why="The constitutional question is access to the records, not entry into carrier property."},
        {text="The government generally needs a warrant for extended historical CSLI.",why="Correct. Carpenter generally requires a probable-cause warrant for extended historical CSLI, subject to exceptions."}}},
      {prompt="What is the most precise challenge to the watches?", correct=1, choices={
        {text="All digital evidence is inadmissible.",why="There is no blanket ban on digital evidence; identify the unlawful acquisition and its causal link."},
        {text="Challenge the CSLI collection and the apartment warrant's reliance on its fruits.",why="Correct. If the affidavit depends on unlawfully obtained CSLI, challenge the downstream search under the exclusionary rule."},
        {text="Carpenter bans real-time tracking in every emergency.",why="Carpenter addresses historical CSLI and does not decide every real-time tracking emergency."}}},
    }
  },
  {
    title="The Bus Stop Patdown", tag="STREET / REASONABLE SUSPICION", setting="A crowded station at dusk",
    facts="An officer sees Jules step off a bus and look around nervously. Jules wears a bulky jacket. The officer has no report of a crime and sees no weapon-like movement. He stops Jules and pats down every pocket, finding a small bag of pills.",
    item="Pills found during a full pocket search", doctrine="Terry v. Ohio · stop and protective frisk",
    witness="witness-two", outcome="SUPPRESS THE PILLS. The stop lacks specific facts, and the frisk exceeded its protective scope.",
    stages={
      {prompt="Which facts matter to whether the stop was justified?", correct=2, choices={
        {text="Nervousness and a bulky jacket, by themselves, prove a crime.",why="A hunch based on vague nervousness and clothing is weak; the officer needs particularized facts."},
        {text="A bus station is a place where anyone may be searched.",why="Public places remain protected by the Fourth Amendment."},
        {text="The officer needs specific, articulable facts supporting reasonable suspicion of crime.",why="Correct. Terry requires specific, articulable facts, not a hunch."}}},
      {prompt="What limits a protective frisk?", correct=2, choices={
        {text="A frisk may search every pocket for evidence once a stop occurs.",why="A stop does not automatically authorize a full evidence search."},
        {text="Terry requires probable cause for every brief stop.",why="Terry allows brief stops on reasonable suspicion; probable cause is not always required."},
        {text="A frisk checks for weapons when the officer reasonably suspects the person is armed and dangerous.",why="Correct. A frisk is a limited weapons check, based on reasonable suspicion the person is armed and dangerous."}}},
      {prompt="How do you attack the pills?", correct=1, choices={
        {text="Move to suppress: neither the stop nor the evidentiary pocket search is justified here.",why="Correct. Challenge both the unsupported stop and the frisk that exceeded its protective purpose."},
        {text="Argue only that the pills were not in plain view.",why="Plain view does not explain how the pills were discovered inside a pocket."},
        {text="Officers must always get warrants in public.",why="Public searches can be lawful under exceptions; the warrant question is not categorical."}}},
    }
  },
  {
    title="The Specific Warrant", tag="HOME / WARRANT SCOPE", setting="A search with clear boundaries",
    facts="After finding probable cause, a neutral judge signs a warrant naming Apartment 4B and a stolen camera with its serial number. Officers execute it at the listed address, knock and announce, then look in a kitchen drawer large enough to hold the camera. Inside they find the camera with the matching serial number. They do not search beyond the warrant's scope.",
    item="Camera found inside the place and scope named by warrant", doctrine="Fourth Amendment · probable cause · particularity · scope",
    witness="witness-one", outcome="MOTION DENIED. The officers used a valid, particular warrant and stayed within its scope.",
    stages={
      {prompt="What parts of the warrant and its execution matter most?", correct=1, choices={
        {text="A neutral judge approved a particular address and a particular stolen camera.",why="Correct. The warrant is supported by probable cause, identifies the apartment and item, and officers stick to its limits."},
        {text="Police have to announce every item they seek during the search.",why="The Fourth Amendment does not require a warrant to list every step during execution."},
        {text="Any warrant lets police search the entire building.",why="This warrant is specific to Apartment 4B, not the whole building."}}},
      {prompt="Was searching the drawer within the warrant's scope?", correct=1, choices={
        {text="Yes. A camera can fit in the drawer, and the warrant named it.",why="Correct. Officers may search places where the described object could reasonably be found."},
        {text="No. Officers may search rooms, never drawers.",why="Containers that can hold the object may be within the warrant's scope."},
        {text="No. After locating the camera, officers may keep searching for unrelated evidence.",why="The facts say the camera was the listed item; unrelated evidence is not the basis for the search."}}},
      {prompt="What should you tell the judge?", correct=1, choices={
        {text="Concede the search was authorized and focus on any independent defense.",why="Correct. On these facts, the warrant is valid and the camera was found within its authorized scope."},
        {text="Move to suppress because officers should have searched without a warrant.",why="A warrant is the reason this search is authorized on this record."},
        {text="The camera is automatically excluded as fruit of the warrant.",why="Evidence obtained within a valid warrant is not automatically fruit of the poisonous tree."}}},
    }
  },
  {
    title="The Extra Twelve Minutes", tag="TRAFFIC / DETENTION", setting="A traffic stop that would not end",
    facts="An officer stops Ren for a broken tail light. She issues a warning, returns Ren's license and papers, and says Ren is free to go. With no new facts suggesting a crime, she orders Ren to wait twelve minutes while a drug dog arrives. The dog alerts and officers search the car.",
    item="Evidence found after the dog sniff", doctrine="Rodriguez v. United States · traffic-stop duration",
    witness="witness-two", outcome="SUPPRESS THE EVIDENCE THAT FOLLOWED THE UNLAWFUL EXTENSION OF THE TRAFFIC STOP.",
    stages={
      {prompt="When did the traffic mission end?", correct=1, choices={
        {text="When the officer finished the warning and returned Ren's papers.",why="Correct. The mission was complete when the warning was issued and Ren's documents were returned."},
        {text="A traffic stop ends only after the driver reaches home.",why="An ordinary traffic stop is a seizure; its length is not measured by the trip home."},
        {text="The stop never ends once a dog is called.",why="Calling a dog does not extend the original stop by itself."}}},
      {prompt="What justification was needed to keep Ren there?", correct=2, choices={
        {text="No additional suspicion, because the stop was lawful at first.",why="The officer may finish traffic tasks but cannot add time for a dog sniff without reasonable suspicion."},
        {text="Probable cause to search the car was automatic after any traffic violation.",why="A traffic violation does not automatically create probable cause to search for unrelated evidence."},
        {text="Reasonable suspicion of another crime was needed to extend the stop.",why="Correct. Under Rodriguez, a traffic stop may not be extended for a dog sniff absent reasonable suspicion."}}},
      {prompt="What is the best suppression argument?", correct=1, choices={
        {text="Move to suppress: the dog sniff unlawfully prolonged the stop, and the alert followed that detention.",why="Correct. The added detention produced the dog alert, so challenge the prolongation and resulting search."},
        {text="The officer could not issue a warning for a tail light.",why="The traffic warning itself is not the constitutional problem described here."},
        {text="Dog sniffs always violate the Fourth Amendment.",why="Dog sniffs are not categorically unconstitutional; the added detention is the issue."}}},
    }
  },
  {
    title="Canvas in the Trunk", tag="VEHICLE / PROBABLE CAUSE", setting="A credible report and a roadside stop",
    facts="A reliable witness gives police specific, recently verified details that a stolen painting is inside a blue van, including its route and a distinctive frame. Officers stop the van on the highway, confirm details through the window, and have probable cause to believe the painting is in the trunk. Without a warrant, they open a portfolio large enough to hold it and find the painting.",
    item="Painting found inside a container in the van", doctrine="Carroll v. United States · automobile exception · scope",
    witness="witness-one", outcome="MOTION DENIED. Probable cause supported this vehicle search, and the portfolio could hold the painting.",
    stages={
      {prompt="What facts support the search?", correct=1, choices={
        {text="Specific, reliable information and police confirmation create probable cause.",why="Correct. Particularized, corroborated facts supply probable cause in this fictional record."},
        {text="A vague anonymous tip always authorizes a vehicle search.",why="An unverified vague tip alone would not automatically establish probable cause."},
        {text="A vehicle can never be searched without a warrant.",why="The automobile exception allows certain vehicle searches on probable cause."}}},
      {prompt="How far does probable cause to search for the painting reach?", correct=1, choices={
        {text="It reaches places and containers where the painting could fit.",why="Correct. The search may reach parts of the vehicle and containers that could conceal the object."},
        {text="It permits opening every container, regardless of size.",why="The search scope tracks the object sought; size still matters."},
        {text="It permits only a visual look through the windows.",why="The automobile exception allows more than looking through windows when probable cause exists."}}},
      {prompt="What should you ask the court to do?", correct=1, choices={
        {text="Concede suppression is unwarranted: the vehicle exception covers this search and its scope.",why="Correct. With probable cause and a container capable of holding the painting, the vehicle exception authorizes the search described."},
        {text="Move to suppress because police always need a warrant for a car.",why="A warrantless vehicle search can be valid under the automobile exception."},
        {text="Suppress it because officers searched a container, even though the painting could fit.",why="A container can be searched when it could hold the object sought."}}},
    }
  },
  {
    title="The Wrong Door", tag="WARRANT / PARTICULARITY", setting="A number off on the warrant",
    facts="A valid warrant names 44 Pine Street, Apartment 4B, and stolen watches. The building has identical neighboring units. Officers' paperwork and the door placard both say 4D, but they force open 4D's door and search it for the watches. The resident of 4D has no connection to the investigation.",
    item="Items found inside the wrong apartment", doctrine="Maryland v. Garrison · warrant execution · reasonable mistake",
    witness="witness-two", outcome="SUPPRESS EVIDENCE FOUND IN APARTMENT 4D. It was outside the warrant's scope.",
    stages={
      {prompt="Which detail changes the execution analysis?", correct=1, choices={
        {text="The apartments look alike, so the warrant covers every unit.",why="Similar layouts do not expand the warrant to all units."},
        {text="Both their paperwork and the door placard clearly said 4D, not the authorized 4B.",why="Correct. The written address and visible placard both identify 4D, while the warrant is for 4B."},
        {text="A search warrant does not have to identify the place to be searched.",why="The warrant must particularly describe the place to be searched."}}},
      {prompt="Can the officers rely on a reasonable mistake here?", correct=2, choices={
        {text="Yes. Any mistake is reasonable, even after discovering it.",why="Garrison allows objectively reasonable mistakes while executing a warrant, but the facts make this one unreasonable."},
        {text="Yes. A valid warrant for the building permits searches of all units.",why="A building warrant does not automatically extend to every separate apartment."},
        {text="No. The clear address information gave no reasonable basis to think 4D was 4B.",why="Correct. The clear mismatch defeats an objectively reasonable belief that 4D was authorized."}}},
      {prompt="What is the strongest motion?", correct=1, choices={
        {text="Move to suppress: they knowingly searched a unit the warrant did not authorize.",why="Correct. The warrant names another apartment, and no reasonable mistake excuses this entry on the stated facts."},
        {text="Warrants can never cover apartments.",why="A warrant may authorize a search of a particular apartment when sufficiently described."},
        {text="Plain view cures the wrong-door entry.",why="Plain view does not retroactively make an unauthorized entry lawful."}}},
    }
  },
}
