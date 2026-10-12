-- Fictional cases for Fourth Counsel. Each turn has one best answer and
-- a short explanation for every choice. This table is designed to be edited.
return {
  {
    title="The Midnight Knock", tier=1, tag="HOME / CONSENT", setting="A quiet block after midnight",
    facts="At 12:14 a.m., officers knock on Mara Vale's door. They have no warrant. She opens it a few inches and says, ‘I don't want you inside.’ Her adult roommate, Eli, walks up behind her and says, ‘Come in, you can look around.’ Officers enter and find a stolen laptop in a shared living room.",
    item="Laptop found in shared living room", doctrine="Georgia v. Randolph · shared-home consent",
    witness="witness-one", outcome="SUPPRESS THE LAPTOP. Mara was present and expressly refused entry.",
    questions={
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
      {prompt="What would change if Mara had left before officers returned and entered?", correct=2, choices={
        {text="Her earlier refusal would always block entry, no matter how much time passed.",why="A former occupant's objection does not necessarily continue after she has left."},
        {text="Randolph's present-objector rule may no longer control once the objector is absent.",why="Correct. Randolph distinguishes a physically present objector from an absent resident; other consent rules may then apply."},
        {text="Eli could never consent to a search of shared space.",why="A co-occupant with common authority can often consent when no present co-occupant objects."}}},
    }
  },
  {
    title="Pocket-Sized Search", tier=2, tag="TRAFFIC / DIGITAL PRIVACY", setting="A roadside stop in the rain",
    facts="After a valid arrest for driving with a suspended license, an officer finds a smartphone in Devon's pocket. Without a warrant, she scrolls through messages and photos. She finds a thread about a recent robbery. There is no emergency and no attempt to remotely wipe the device.",
    item="Messages and photos copied from phone", doctrine="Riley v. California · digital data incident to arrest",
    witness="witness-two", outcome="SUPPRESS THE PHONE CONTENTS. Riley generally requires a warrant to search phone data.",
    questions={
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
      {prompt="What does Riley say about the phone's physical seizure?", correct=3, choices={
        {text="Police must leave a phone behind whenever they arrest its owner.",why="A lawful arrest may permit officers to seize and secure the physical phone."},
        {text="A valid arrest automatically permits a complete forensic extraction.",why="Riley separates taking the device from searching its digital contents."},
        {text="Officers may secure the phone while generally seeking a warrant before examining its data.",why="Correct. Riley generally requires a warrant to search digital contents, while recognizing officers can secure the device against loss or remote wiping."}}},
    }
  },
  {
    title="The Apartment Signal", tier=3, tag="LOCATION / WARRANT", setting="A month of quiet pings",
    facts="Investigators obtain 30 days of historical cell-site location information for Niko's phone from his carrier. They have no warrant. The records place Niko near a series of warehouse break-ins. Police use the data to get a warrant for his apartment, where they find stolen watches.",
    item="Thirty days of historical cell-site location data", doctrine="Carpenter v. United States · historical CSLI",
    witness="witness-one", outcome="SUPPRESS THE WATCHES IF THE APARTMENT WARRANT DEPENDED ON THE UNLAWFUL LOCATION RECORDS.",
    questions={
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
      {prompt="What fact is most important to whether the apartment evidence is excluded?", correct=2, choices={
        {text="Whether the warrant affidavit relied on the CSLI and whether independent lawful facts support it.",why="Correct. Suppression of downstream evidence turns on the connection to the unlawful collection and any independent source or attenuation."},
        {text="Whether the watches were valuable enough to investigate.",why="The seriousness of the suspected crime does not by itself cure an unlawful search."},
        {text="Whether Niko used the phone every day.",why="Frequency of use is not the key exclusionary-rule question here."}}},
    }
  },
  {
    title="The Bus Stop Patdown", tier=1, tag="STREET / REASONABLE SUSPICION", setting="A crowded station at dusk",
    facts="An officer sees Jules step off a bus and look around nervously. Jules wears a bulky jacket. The officer has no report of a crime and sees no weapon-like movement. He stops Jules and pats down every pocket, finding a small bag of pills.",
    item="Pills found during a full pocket search", doctrine="Terry v. Ohio · stop and protective frisk",
    witness="witness-two", outcome="SUPPRESS THE PILLS. The stop lacks specific facts, and the frisk exceeded its protective scope.",
    questions={
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
      {prompt="Suppose Jules was lawfully stopped but the officer felt a hard object that could be a weapon. What may the frisk allow?", correct=2, choices={
        {text="A limited check for weapons if the officer reasonably believes Jules may be armed and dangerous.",why="Correct. A frisk is a protective weapons search, not a general evidence search."},
        {text="A full pocket search for anything that might be evidence.",why="The frisk does not become a general search just because the stop is lawful."},
        {text="Nothing at all; a lawful stop can never include a frisk.",why="Terry permits a limited frisk when the armed-and-dangerous standard is met."}}},
    }
  },
  {
    title="The Specific Warrant", tier=1, tag="HOME / WARRANT SCOPE", setting="A search with clear boundaries",
    facts="After finding probable cause, a neutral judge signs a warrant naming Apartment 4B and a stolen camera with its serial number. Officers execute it at the listed address, knock and announce, then look in a kitchen drawer large enough to hold the camera. Inside they find the camera with the matching serial number. They do not search beyond the warrant's scope.",
    item="Camera found inside the place and scope named by warrant", doctrine="Fourth Amendment · probable cause · particularity · scope",
    witness="witness-one", outcome="MOTION DENIED. The officers used a valid, particular warrant and stayed within its scope.",
    questions={
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
      {prompt="Why does the camera's size matter when officers open the drawer?", correct=1, choices={
        {text="A place may be searched if the listed object could reasonably fit there.",why="Correct. The warrant's object and the place searched must match in a practical way."},
        {text="Once officers have a warrant, every drawer is automatically in scope.",why="The scope still depends on where the described item could be found."},
        {text="A drawer can only be searched if it is named word-for-word in the warrant.",why="Warrants need particularity, but officers may search locations capable of holding the listed item."}}},
    }
  },
  {
    title="The Extra Twelve Minutes", tier=2, tag="TRAFFIC / DETENTION", setting="A traffic stop that would not end",
    facts="An officer stops Ren for a broken tail light. She issues a warning, returns Ren's license and papers, and says Ren is free to go. With no new facts suggesting a crime, she orders Ren to wait twelve minutes while a drug dog arrives. The dog alerts and officers search the car.",
    item="Evidence found after the dog sniff", doctrine="Rodriguez v. United States · traffic-stop duration",
    witness="witness-two", outcome="SUPPRESS THE EVIDENCE THAT FOLLOWED THE UNLAWFUL EXTENSION OF THE TRAFFIC STOP.",
    questions={
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
      {prompt="What if the dog sniff happened while the officer was still diligently handling the traffic warning, without adding time?", correct=3, choices={
        {text="Any dog sniff automatically adds an unlawful detention.",why="The timing matters; a sniff that adds no time to an otherwise lawful stop is different."},
        {text="The officer may extend the stop indefinitely after writing a warning.",why="The stop still cannot be prolonged beyond its traffic mission without additional justification."},
        {text="Rodriguez bars added time for the sniff, but not a sniff that does not extend the stop.",why="Correct. The constitutional issue is prolonging the seizure beyond the time reasonably needed for the traffic mission."}}},
    }
  },
  {
    title="Canvas in the Trunk", tier=2, tag="VEHICLE / PROBABLE CAUSE", setting="A credible report and a roadside stop",
    facts="A reliable witness gives police specific, recently verified details that a stolen painting is inside a blue van, including its route and a distinctive frame. Officers stop the van on the highway, confirm details through the window, and have probable cause to believe the painting is in the trunk. Without a warrant, they open a portfolio large enough to hold it and find the painting.",
    item="Painting found inside a container in the van", doctrine="Carroll v. United States · automobile exception · scope",
    witness="witness-one", outcome="MOTION DENIED. Probable cause supported this vehicle search, and the portfolio could hold the painting.",
    questions={
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
      {prompt="What is the limiting principle on the officers' search?", correct=2, choices={
        {text="Probable cause to search the van permits a search of every person inside it.",why="A vehicle search does not automatically authorize a search of occupants' bodies."},
        {text="They may search only vehicle areas and containers where the painting could fit.",why="Correct. The permissible scope follows the object of the search and the places it could reasonably be concealed."},
        {text="They may search only the trunk, never a container within it.",why="A container can be searched if it could hold the object supported by probable cause."}}},
    }
  },
  {
    title="The Wrong Door", tier=3, tag="WARRANT / PARTICULARITY", setting="A number off on the warrant",
    facts="A valid warrant names 44 Pine Street, Apartment 4B, and stolen watches. The building has identical neighboring units. Officers' paperwork and the door placard both say 4D, but they force open 4D's door and search it for the watches. The resident of 4D has no connection to the investigation.",
    item="Items found inside the wrong apartment", doctrine="Maryland v. Garrison · warrant execution · reasonable mistake",
    witness="witness-two", outcome="SUPPRESS EVIDENCE FOUND IN APARTMENT 4D. It was outside the warrant's scope.",
    questions={
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
      {prompt="At what point should the officers stop and reassess the warrant's scope?", correct=3, choices={
        {text="Only after they find the stolen watches.",why="Finding evidence does not excuse continuing a search at a place the warrant does not authorize."},
        {text="They may finish once the door is forced, even if they see the mismatch.",why="A forced entry does not expand the warrant."},
        {text="When the clear address information shows they are at 4D rather than 4B.",why="Correct. Officers must stop or reassess when they know the place they entered is outside the warrant's authorized scope."}}},
    }
  },
  {
    title="The 3 A.M. Entry", tier=3, tag="HOME / ARREST WARRANT", setting="A quiet house before sunrise",
    facts="Police believe Kai committed a felony and see him enter his own home. They have no arrest warrant or search warrant. Officers force the front door to arrest him. No one invited them in, and there is no emergency, hot pursuit, or immediate threat.",
    item="Evidence observed after the warrantless home entry", doctrine="Payton v. New York · home entry to make an arrest",
    witness="witness-one", outcome="SUPPRESS EVIDENCE OBTAINED THROUGH THE UNJUSTIFIED WARRANTLESS ENTRY, SUBJECT TO EXCEPTIONS AND THE FULL RECORD.",
    questions={
      {prompt="What makes this entry constitutionally different from an arrest in public?", correct=2, choices={
        {text="Police may enter any home if they have probable cause for a felony.",why="Probable cause alone generally does not authorize a nonconsensual, nonexigent home entry to arrest someone."},
        {text="The home receives special protection; officers generally need an arrest warrant to enter the suspect's home, absent consent or exigency.",why="Correct. Payton generally bars warrantless, nonconsensual entry into a suspect's home to make a routine felony arrest when no exigency exists."},
        {text="A home has no Fourth Amendment protection when the police are making an arrest.",why="An arrest does not erase the home's distinct Fourth Amendment protection."}}},
      {prompt="What could an arrest warrant ordinarily authorize at Kai's own home?", correct=1, choices={
        {text="Entry when officers have reason to believe Kai lives there and is inside, subject to the warrant's limits.",why="Correct. Payton recognizes limited authority to enter the suspect's own home to execute an arrest warrant when officers reasonably believe the suspect is inside."},
        {text="A search of every room for evidence of the felony.",why="An arrest warrant is not a general evidence-search warrant."},
        {text="Entry into any neighbor's home where Kai might be hiding.",why="Entry into a third party's home generally raises separate warrant requirements."}}},
      {prompt="Which fact would most directly support a warrantless entry here?", correct=3, choices={
        {text="The officers have a strong case and want to prevent delay.",why="The seriousness of an investigation alone is not an exigent circumstance."},
        {text="Kai's home is close to the street.",why="Proximity to a public street does not waive the home's protection."},
        {text="A genuine emergency or another recognized exigent circumstance makes immediate entry objectively necessary.",why="Correct. Exigent circumstances can justify some warrantless home entries, but the scenario expressly excludes one."}}},
      {prompt="What should the defense connect to the entry when seeking suppression?", correct=1, choices={
        {text="Identify evidence obtained as a result of the unlawful entry and address any independent source or other exception.",why="Correct. Suppression analysis follows the causal connection and recognizes doctrines such as independent source and attenuation."},
        {text="Demand that every item Kai has ever owned be excluded.",why="The remedy is not automatically unlimited; connect the challenged evidence to the entry."},
        {text="Argue that probable cause is irrelevant to every arrest.",why="Probable cause still matters; the issue is the additional home-entry requirement."}}},
    }
  },
  {
    title="Search After Arrest", tier=4, tag="VEHICLE / SEARCH INCIDENT TO ARREST", setting="A traffic arrest and a locked patrol car",
    facts="After arresting Morgan for driving with a suspended license, officers handcuff Morgan and secure them in a patrol car. They search the passenger compartment of Morgan's vehicle and open a backpack, hoping to find evidence of an unrelated burglary. There is no reason to believe evidence of the license offense is in the vehicle, and no other exception applies.",
    item="Evidence found in a backpack inside the passenger compartment", doctrine="Arizona v. Gant · vehicle search incident to arrest",
    witness="witness-two", outcome="SUPPRESS THE BACKPACK EVIDENCE. NEITHER GANT BASIS FOR A VEHICLE SEARCH INCIDENT TO ARREST IS PRESENT.",
    questions={
      {prompt="Which two conditions can authorize a vehicle search incident to an arrest?", correct=2, choices={
        {text="Any custodial arrest automatically permits a complete search of the vehicle.",why="A custodial arrest does not create a blanket vehicle-search power."},
        {text="The arrestee can reach the passenger compartment at the time of the search, or officers reasonably believe it contains evidence of the offense of arrest.",why="Correct. Gant recognizes these two distinct bases for a vehicle search incident to arrest."},
        {text="The officer suspects the vehicle may contain evidence of any crime, whether related to the arrest or not.",why="The evidence-of-offense basis concerns the offense of arrest; another crime would need its own justification."}}},
      {prompt="Does the reaching-distance basis apply to Morgan?", correct=3, choices={
        {text="Yes. Anyone arrested near a car can reach inside it later.",why="The question is whether the arrestee could access the passenger compartment at the time of the search."},
        {text="Yes. Handcuffs never matter to the analysis.",why="The actual ability to reach the compartment is relevant under Gant's first basis."},
        {text="No. Morgan was handcuffed and secured in the patrol car when officers searched.",why="Correct. The facts remove the access-to-the-compartment rationale."}}},
      {prompt="Could officers use the evidence-of-offense basis to look for burglary evidence?", correct=1, choices={
        {text="Not on these facts: the arrest was for driving with a suspended license, and there is no reason to expect evidence of that offense in the vehicle.",why="Correct. The search cannot rely on unrelated suspected burglary evidence under Gant's evidence-of-the-offense prong."},
        {text="Yes. Evidence of any suspected crime always qualifies under Gant.",why="That would erase the requirement tying this prong to the offense of arrest."},
        {text="Yes. A suspended-license arrest automatically creates probable cause to search for burglary evidence.",why="The stated offense does not establish probable cause for an unrelated burglary search."}}},
      {prompt="How should you frame the motion?", correct=2, choices={
        {text="Suppress the vehicle itself because it was parked near the arrest.",why="The motion should target the challenged search and evidence, not treat proximity alone as a constitutional violation."},
        {text="Move to suppress evidence from the passenger-compartment search because neither Gant justification applies and no other exception is given.",why="Correct. The scenario forecloses both Gant bases and says no independent exception applies."},
        {text="Argue that officers may never search a vehicle after any arrest.",why="Gant permits vehicle searches in defined circumstances."}}},
    }
  },
  {
    title="The Paper Bag", tier=4, tag="CONSENT / SEARCH SCOPE", setting="A consent search on the shoulder",
    facts="During a lawful traffic stop, an officer says, ‘I suspect you have narcotics. May I search your car?’ Lee replies, ‘Go ahead.’ Lee does not limit the consent. In the passenger area, the officer finds an ordinary paper bag large enough to hold narcotics and opens it. There is no claim of coercion or revocation.",
    item="Narcotics found inside the paper bag", doctrine="Florida v. Jimeno · objective scope of consent",
    witness="witness-two", outcome="MOTION DENIED ON THESE FACTS. A REASONABLE PERSON COULD UNDERSTAND THE UNLIMITED CAR SEARCH FOR NARCOTICS TO INCLUDE THIS BAG.",
    questions={
      {prompt="How is the scope of Lee's consent measured?", correct=1, choices={
        {text="By what a typical reasonable person would have understood from the exchange between Lee and the officer.",why="Correct. Jimeno applies an objective-reasonableness standard to the scope of consent."},
        {text="Only by the officer's unspoken expectations.",why="The scope is not measured solely by what the officer privately intended."},
        {text="Every consent automatically includes every container and locked device.",why="Consent has limits; the object sought and the exchange matter."}}},
      {prompt="Does the permission to search for narcotics ordinarily reach this paper bag?", correct=2, choices={
        {text="No. Consent to search a car never includes a container inside it.",why="Jimeno rejects a categorical rule excluding all containers from vehicle consent searches."},
        {text="Yes, on these facts: a reasonable person could understand an unrestricted search for narcotics to include a bag capable of holding them.",why="Correct. The object sought and the absence of a limitation make opening this bag objectively reasonable."},
        {text="Only if the officer first obtains a second warrant for the bag.",why="Voluntary consent can authorize a search within its objectively reasonable scope."}}},
      {prompt="What change would make opening a container less likely to fall within consent?", correct=3, choices={
        {text="The bag is visible in the passenger area.",why="Visibility alone does not determine whether the consent covers opening it."},
        {text="The officer stated the suspected drug type before asking.",why="That detail can help explain what a reasonable person would understand the search to seek."},
        {text="Lee clearly limits consent to looking only under the seats and the officer opens a closed bag instead.",why="Correct. A clear limitation controls the scope; officers cannot ignore it."}}},
      {prompt="What is the best defense argument if the officer opens a locked briefcase after the same exchange?", correct=1, choices={
        {text="Argue the locked briefcase falls outside the objectively reasonable scope, especially if its contents or the exchange show the limit; analyze the exact facts.",why="Correct. Jimeno's rule is contextual, and its opinion distinguished a locked briefcase; do not assume every container is covered."},
        {text="Consent to search a car always authorizes forcing open any locked container.",why="That overstates the scope of consent and ignores the circumstances and expressed limits."},
        {text="The officer must stop searching as soon as any container is found.",why="A container is not categorically off-limits; its size, contents, and the consent exchange matter."}}},
    }
  },
  {
    title="The Covered Motorcycle", tier=4, tag="HOME / VEHICLE EXCEPTION", setting="A tarp beside the house",
    facts="Police have probable cause to believe a motorcycle parked under a tarp on a home's enclosed side patio is stolen. The patio is part of the home's curtilage. Without a warrant, consent, or exigency, an officer walks onto the patio and lifts the tarp to inspect the motorcycle.",
    item="Information and evidence obtained by entering the patio and uncovering the motorcycle", doctrine="Collins v. Virginia · automobile exception and curtilage",
    witness="witness-one", outcome="SUPPRESS EVIDENCE GAINED THROUGH THE WARRANTLESS CURTILAGE ENTRY, SUBJECT TO ANY INDEPENDENT EXCEPTION OR SOURCE.",
    questions={
      {prompt="Why is probable cause to search the motorcycle not the end of the analysis?", correct=3, choices={
        {text="Probable cause is never enough to search a vehicle anywhere.",why="The automobile exception can permit warrantless vehicle searches when its requirements are met."},
        {text="The tarp makes the motorcycle immune from every search.",why="The question is the officer's authority to enter the protected area, not a categorical tarp rule."},
        {text="The officer also entered the home's curtilage, a separate protected area.",why="Correct. Collins holds the automobile exception does not itself authorize a warrantless entry into a home's curtilage to reach a vehicle there."}}},
      {prompt="What does the automobile exception authorize on these facts by itself?", correct=2, choices={
        {text="It automatically authorizes entry into any private driveway or home area to reach a vehicle.",why="The vehicle exception does not erase the separate protection of the home and curtilage."},
        {text="It may justify searching a vehicle on probable cause, but it does not supply the missing authority to enter the curtilage.",why="Correct. Collins separates the vehicle-search rationale from lawful access to the vehicle in a protected home area."},
        {text="It applies only after the vehicle has been seized and towed away.",why="The automobile exception is not limited to searches after impoundment."}}},
      {prompt="What additional fact could independently change the entry analysis?", correct=1, choices={
        {text="A valid warrant or a genuine exigency authorizing the intrusion.",why="Correct. Collins left room for other recognized justifications; the scenario says none is present."},
        {text="The officer has probable cause, without any further justification to enter the curtilage.",why="Probable cause for the vehicle does not by itself authorize crossing into the protected curtilage."},
        {text="The motorcycle can be driven away quickly.",why="Mobility supports the vehicle exception but does not by itself authorize entry into the curtilage."}}},
      {prompt="What should your motion focus on?", correct=2, choices={
        {text="Argue that all searches of motorcycles are unconstitutional.",why="There is no categorical ban on searching motorcycles."},
        {text="Challenge the warrantless entry into curtilage and connect the challenged evidence to that intrusion.",why="Correct. The focused issue is the separate home-area intrusion and its fruits."},
        {text="Claim the motorcycle's mobility automatically makes the patio public.",why="A vehicle's mobility does not change the status of the surrounding curtilage."}}},
    }
  },
}
