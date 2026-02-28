import SwiftUI

// MARK: - Category Enum
// Using a String-backed enum for Codable conformance and human-readable serialization.
// Sendable conformance is free for enums with no mutable state — important for Swift 6 concurrency.
enum SurvivalCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case medical = "Medical"
    case auto    = "Auto"
    case urban   = "Urban"
    case wild    = "Wild"
    case tools   = "Tools"
    
    var id: String { rawValue }
    
    /// SF Symbol representing each category tab
    var iconName: String {
        switch self {
        case .medical: return "cross.case.fill"
        case .auto:    return "car.fill"
        case .urban:   return "building.2.fill"
        case .wild:    return "leaf.fill"
        case .tools:   return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - SurvivalItem Model
// Lightweight, value-type model. Codable for potential JSON export.
// Sendable ensures safe usage across concurrency boundaries in Swift 6.
struct SurvivalItem: Identifiable, Codable, Sendable {
    let id: Int
    let title: String
    let category: SurvivalCategory
    let iconName: String   // SF Symbol name — zero asset cost
    let isLocked: Bool
    let steps: [String]    // Instruction steps for unlocked items
}

// MARK: - Static Data Source
// All 50 items are compiled into the binary — no file I/O, no network.
// This is the most size-efficient approach: zero JSON parsing overhead at runtime.
// Content sourced from Red Cross, NHS, AAA, FEMA, NPS, and wilderness survival guides.
struct SurvivalData: Sendable {
    
    static let items: [SurvivalItem] = [
        // ─────────────────────────────────────────
        // MEDICAL (1–10)
        // ─────────────────────────────────────────
        SurvivalItem(id: 1, title: "CPR", category: .medical, iconName: "heart.fill", isLocked: false, steps: [
            "Check the scene for safety and call for help.",
            "Place the heel of your hand on the center of the chest.",
            "Push hard and fast — 2 inches deep, 100–120 BPM.",
            "After 30 compressions, give 2 rescue breaths.",
            "Continue until help arrives or an AED is available."
        ]),
        SurvivalItem(id: 2, title: "Stop Bleeding", category: .medical, iconName: "drop.fill", isLocked: false, steps: [
            "Put on gloves or use a barrier to protect yourself.",
            "Apply firm, direct pressure to the wound with a clean cloth or gauze.",
            "If blood soaks through, add more layers — do not remove the first one.",
            "If the wound is on a limb with no embedded object, elevate it above the heart.",
            "Maintain steady pressure until bleeding stops or emergency services arrive.",
            "If bleeding is life-threatening, apply a tourniquet 2–3 inches above the wound."
        ]),
        SurvivalItem(id: 3, title: "Treat Burns", category: .medical, iconName: "flame.fill", isLocked: false, steps: [
            "Remove the person from the heat source immediately.",
            "Cool the burn under cool running water for at least 20 minutes.",
            "Do NOT use ice, butter, toothpaste, or greasy substances.",
            "Carefully remove jewelry or clothing near the burn — not if stuck to skin.",
            "Cover loosely with cling film or a clean, non-fluffy dressing.",
            "Seek medical help for burns larger than the palm, or on the face/hands/joints."
        ]),
        SurvivalItem(id: 4, title: "Splint a Fracture", category: .medical, iconName: "bandage.fill", isLocked: false, steps: [
            "Do NOT attempt to realign the bone or push it back in.",
            "Immobilize the injured area — splint it in the position you found it.",
            "Use rigid material (sticks, boards, rolled magazines) as a splint.",
            "Pad the splint with soft material (cloth, towels) for comfort.",
            "Secure the splint with tape, strips of cloth, or belts — snug but not tight.",
            "Check circulation beyond the splint: monitor fingers/toes for numbness or color change."
        ]),
        SurvivalItem(id: 5, title: "Heimlich Maneuver", category: .medical, iconName: "lungs.fill", isLocked: false, steps: [
            "Ask 'Are you choking?' — if they cannot speak, cough, or breathe, act immediately.",
            "Stand behind the person. Give 5 firm back blows between the shoulder blades.",
            "If unsuccessful, wrap your arms around their waist from behind.",
            "Make a fist and place it just above the navel, below the ribcage.",
            "Grasp your fist with the other hand — deliver 5 quick inward and upward thrusts.",
            "Alternate 5 back blows and 5 abdominal thrusts until the object is expelled."
        ]),
        SurvivalItem(id: 6, title: "Treat Hypothermia", category: .medical, iconName: "thermometer.snowflake", isLocked: false, steps: [
            "Move the person to a warm, sheltered area immediately.",
            "Remove any wet clothing and replace with dry layers or blankets.",
            "Warm the core first — focus on chest, neck, head, and groin area.",
            "Use body-to-body contact under blankets if no other heat source is available.",
            "Offer warm, sweet drinks if they are conscious and can swallow. Never give alcohol.",
            "Handle them gently — sudden movements can cause dangerous heart rhythms."
        ]),
        SurvivalItem(id: 7, title: "Snake Bite Protocol", category: .medical, iconName: "allergens.fill", isLocked: false, steps: [
            "Move away from the snake — do not attempt to catch or kill it.",
            "Keep the victim calm and still to slow venom spread.",
            "Remove jewelry, watches, and tight clothing near the bite before swelling starts.",
            "Immobilize the bitten limb and keep it at or below heart level.",
            "Do NOT cut the wound, suck out venom, apply ice, or use a tourniquet.",
            "Call emergency services immediately. Note the snake's appearance if safe to do so."
        ]),
        SurvivalItem(id: 8, title: "Allergic Reaction", category: .medical, iconName: "exclamationmark.triangle.fill", isLocked: false, steps: [
            "Recognize anaphylaxis: swelling of face/throat, difficulty breathing, hives, rapid pulse, dizziness.",
            "Call emergency services immediately — anaphylaxis can be fatal within minutes.",
            "If the person has an EpiPen: remove the safety cap and press firmly into the outer thigh (through clothing is OK).",
            "Hold the EpiPen in place for 10 seconds, then remove and massage the injection site.",
            "Lay the person flat with legs elevated. If they're vomiting, place them on their side.",
            "A second dose may be needed after 5–15 minutes if symptoms don't improve. Save the used EpiPen to show medics."
        ]),
        SurvivalItem(id: 9, title: "Dehydration Treatment", category: .medical, iconName: "drop.triangle.fill", isLocked: false, steps: [
            "Recognize signs: dry mouth, dark urine, dizziness, rapid heartbeat, confusion.",
            "Move the person to a cool, shaded area.",
            "Give small, frequent sips of water — not large gulps.",
            "If available, use oral rehydration salts (ORS) or mix: 1L water + 6 tsp sugar + ½ tsp salt.",
            "Avoid caffeine, alcohol, and sugary drinks — these worsen dehydration.",
            "Seek medical help if the person is confused, not urinating, or vomiting repeatedly."
        ]),
        SurvivalItem(id: 10, title: "Improvised Stretcher", category: .medical, iconName: "bed.double.fill", isLocked: false, steps: [
            "Find two sturdy poles (6–7 ft long) — branches, pipes, or broom handles.",
            "Lay a large blanket, tarp, or two buttoned-up jackets between the poles.",
            "If using jackets, thread poles through the sleeves with jackets zipped/buttoned shut.",
            "Secure the fabric so it won't slide — fold edges around poles and pin or tie.",
            "Test the stretcher with weight before placing the injured person on it.",
            "Lift with bent knees, carry low, and communicate with your partner at every step."
        ]),
        SurvivalItem(id: 52, title: "Treat Heat Stroke", category: .medical, iconName: "thermometer.sun.fill", isLocked: false, steps: [
            "Call 911 immediately — heat stroke is life-threatening. Body temperature exceeds 103°F (39.4°C).",
            "Move the person to the coolest area available — shade, air-conditioned room, or vehicle with AC.",
            "Remove excess clothing. Cool them rapidly: immerse in cold water if possible (most effective method).",
            "If no tub: apply ice packs to neck, armpits, and groin — where blood vessels are near the surface.",
            "Fan the person while misting skin with cool water. Soak their clothing with cool water.",
            "Do NOT give fluids if the person is confused or unconscious. Monitor breathing until help arrives."
        ]),
        SurvivalItem(id: 53, title: "Recognize a Stroke", category: .medical, iconName: "brain.head.profile", isLocked: false, steps: [
            "Use BE FAST: Balance loss, Eyes (blurred vision), Face drooping, Arm weakness, Speech slurred, Time to call 911.",
            "Ask the person to SMILE — does one side of their face droop?",
            "Ask them to RAISE BOTH ARMS — does one arm drift downward?",
            "Ask them to REPEAT a simple phrase — is their speech slurred or strange?",
            "Note the EXACT TIME symptoms started — doctors need this to choose the right treatment.",
            "Do NOT give aspirin, food, or drink. Lay them on their side with head elevated. Call 911 immediately."
        ]),
        SurvivalItem(id: 54, title: "Insect Sting Treatment", category: .medical, iconName: "ant.fill", isLocked: false, steps: [
            "Remove the stinger immediately by scraping sideways with a credit card or fingernail — do NOT squeeze it.",
            "Wash the area with soap and water. Apply a cold pack wrapped in cloth for 10 minutes to reduce swelling.",
            "Take an antihistamine if available to reduce itching and mild allergic response.",
            "Watch for anaphylaxis: difficulty breathing, swelling of face/throat, rapid pulse — use EpiPen if available.",
            "For spider bites: clean the wound, apply ice, and seek medical attention — especially brown recluse or black widow.",
            "Prevent infection: keep the area clean and avoid scratching. See a doctor if redness spreads or fever develops."
        ]),
        SurvivalItem(id: 55, title: "Recovery Position", category: .medical, iconName: "person.fill", isLocked: false, steps: [
            "Use for unconscious people who ARE breathing — keeps their airway open and prevents choking on vomit.",
            "Kneel beside the person. Place the arm nearest to you at a right angle, palm facing up.",
            "Bring the far arm across their chest and hold the back of their hand against their nearest cheek.",
            "With your other hand, pull the far knee up so the foot is flat on the ground.",
            "Pull the bent knee toward you to roll them onto their side. Adjust the top leg so hip and knee are at right angles.",
            "Tilt their head back slightly to keep the airway open. Monitor breathing continuously until help arrives."
        ]),
        
        // ─────────────────────────────────────────
        // AUTO (11–20)
        // ─────────────────────────────────────────
        SurvivalItem(id: 11, title: "Change Tire", category: .auto, iconName: "circle.circle.fill", isLocked: false, steps: [
            "Engage parking brake and place wheel chocks behind tires.",
            "Locate the jack point on the vehicle frame.",
            "Position jack and raise vehicle until tire clears ground.",
            "Loosen and remove lug nuts, then remove flat tire.",
            "Mount spare tire, hand-tighten lug nuts in star pattern.",
            "Lower vehicle and torque lug nuts to spec."
        ]),
        SurvivalItem(id: 12, title: "Jump Start Battery", category: .auto, iconName: "battery.100.bolt", isLocked: false, steps: [
            "Park both cars close together but NOT touching. Turn off both engines.",
            "Connect RED clamp to the POSITIVE (+) terminal of the dead battery.",
            "Connect other RED clamp to the POSITIVE (+) terminal of the good battery.",
            "Connect BLACK clamp to the NEGATIVE (−) terminal of the good battery.",
            "Connect other BLACK clamp to an unpainted metal surface on the dead car's engine block.",
            "Start the working car, wait 3–5 minutes, then start the dead car.",
            "Remove cables in REVERSE order. Drive the revived car for 20+ minutes to recharge."
        ]),
        SurvivalItem(id: 13, title: "Escape Sinking Car", category: .auto, iconName: "car.side.fill", isLocked: false, steps: [
            "Stay calm — you have about 30–60 seconds to act before water pressure traps you.",
            "Unbuckle your seatbelt immediately. Help children unbuckle oldest to youngest.",
            "Do NOT open the doors — this floods the cabin instantly.",
            "Open or roll down the window. Power windows may work for ~1 minute after submersion.",
            "If windows won't open, use a window-breaking tool to strike the corner of a side window.",
            "Exit through the window, pushing children out first. Swim toward the surface."
        ]),
        SurvivalItem(id: 14, title: "Engine Overheat Fix", category: .auto, iconName: "thermometer.sun.fill", isLocked: false, steps: [
            "Turn off the A/C immediately and turn the heater to MAX — this pulls heat from the engine.",
            "If the temperature gauge continues to rise, pull over safely and turn off the engine.",
            "Wait at least 30 minutes for the engine to cool. Do NOT open the radiator cap while hot.",
            "Check coolant level. If low, carefully add coolant or water once the engine is cool.",
            "Inspect for visible leaks under the car — green, orange, or pink fluid indicates a coolant leak.",
            "Drive slowly to the nearest service station. If it overheats again, stop and call for help."
        ]),
        SurvivalItem(id: 15, title: "Patch Radiator Hose", category: .auto, iconName: "wrench.fill", isLocked: false, steps: [
            "Let the engine cool completely — coolant can cause severe burns.",
            "Locate the leak in the hose by looking for wet spots, steam, or dripping coolant.",
            "Clean and dry the area around the leak as much as possible.",
            "Wrap the damaged area tightly with duct tape or silicone repair tape.",
            "Overlap each layer by half the tape width. Apply at least 4–5 layers.",
            "Refill coolant (or use water temporarily) and drive to the nearest mechanic. This is temporary."
        ]),
        SurvivalItem(id: 16, title: "Car Stuck in Snow", category: .auto, iconName: "snowflake", isLocked: false, steps: [
            "Do NOT spin your wheels — this digs you deeper and melts ice into a slick surface.",
            "Clear snow and ice from around all four tires using a shovel, floor mat, or even your hands.",
            "Place traction material in front of the drive wheels: floor mats, sand, cat litter, branches, or cardboard.",
            "Turn off traction control. Gently accelerate in a low gear — ease on and off the gas to 'rock' the car.",
            "Let a little air out of your tires (re-inflate ASAP) — softer tires grip better on snow and ice.",
            "If rocking doesn't work, have others push while you gently accelerate. Never stand behind spinning wheels."
        ]),
        SurvivalItem(id: 17, title: "Tow with Rope", category: .auto, iconName: "link", isLocked: false, steps: [
            "Use a proper tow rope or strap rated for the vehicle's weight. Do NOT use bungee cords.",
            "Attach the strap to designated tow hooks on both vehicles — not bumpers or axles.",
            "Keep the tow strap taut with minimal slack to prevent jerking.",
            "The towed vehicle must have its ignition ON for steering and brakes to work.",
            "Drive slowly (under 25 mph) and use hazard lights on both vehicles.",
            "Brake gently and signal well in advance. Maintain constant communication."
        ]),
        SurvivalItem(id: 18, title: "Car Accident Response", category: .auto, iconName: "car.2.fill", isLocked: false, steps: [
            "Ensure your own safety first — turn off your engine, engage the parking brake, and turn on hazard lights.",
            "Call emergency services (911). State the location, number of vehicles, and if anyone is injured.",
            "Check on all people involved. Do NOT move injured persons unless there's immediate danger (fire, submersion).",
            "If someone is bleeding, apply direct pressure. If unconscious but breathing, place in the recovery position.",
            "Set up warning triangles or flares 50–100 feet behind the scene to alert oncoming traffic.",
            "Exchange information with other drivers (name, insurance, license plate) but do NOT admit fault."
        ]),
        SurvivalItem(id: 19, title: "Emergency Brake Fix", category: .auto, iconName: "exclamationmark.triangle.fill", isLocked: false, steps: [
            "If your brakes fail while driving: take your foot off the gas immediately.",
            "Pump the brake pedal rapidly — this may rebuild hydraulic pressure.",
            "Downshift through gears gradually to use engine braking (Manual: shift down; Auto: move to L or 2).",
            "Apply the parking/emergency brake slowly and steadily — never slam it.",
            "Use friction: steer toward an uphill incline or gently rub against a curb or guardrail.",
            "Once stopped, turn on hazard lights. Do NOT drive the vehicle — call for a tow."
        ]),
        SurvivalItem(id: 20, title: "Roadside Breakdown", category: .auto, iconName: "exclamationmark.shield.fill", isLocked: false, steps: [
            "Pull completely off the road onto a flat, stable surface. Turn on hazard lights immediately.",
            "Stay inside the vehicle with your seatbelt on if on a highway — it's safer than standing outside.",
            "If you must exit, do so from the side AWAY from traffic. Wear bright or reflective clothing.",
            "Set up reflective triangles or flares at least 100 feet behind your vehicle.",
            "Raise the hood and tie a bright cloth to the antenna or door handle to signal distress.",
            "Call roadside assistance or emergency services. Share your exact location using mile markers or GPS."
        ]),
        
        // ─────────────────────────────────────────
        // URBAN (21–30)
        // ─────────────────────────────────────────
        SurvivalItem(id: 21, title: "Tornado Protocol", category: .urban, iconName: "tornado", isLocked: false, steps: [
            "Know the difference: WATCH means conditions are favorable; WARNING means a tornado has been spotted — act NOW.",
            "Go to the LOWEST floor of a sturdy building. Interior rooms (bathroom, closet) with no windows are safest.",
            "Get UNDER something sturdy — a heavy table or mattress. Protect your head and neck with your arms.",
            "If in a mobile home: LEAVE immediately. Mobile homes offer almost no protection — go to a sturdy building.",
            "If caught outside with no shelter: lie flat in the lowest area (ditch) and cover your head. Stay away from trees and cars.",
            "After it passes: watch for downed power lines, gas leaks, and structural damage. Do not enter damaged buildings."
        ]),
        SurvivalItem(id: 22, title: "Fire Escape Plan", category: .urban, iconName: "flame.circle.fill", isLocked: false, steps: [
            "Identify TWO exit routes from every room in your home — door + window.",
            "Install smoke alarms on every level and test monthly. Replace batteries yearly.",
            "Practice your escape plan with everyone in the household at least twice a year.",
            "If you encounter smoke, get LOW — crawl on your hands and knees to stay under the smoke.",
            "Feel doors before opening — if hot, use the alternate exit. Never open a hot door.",
            "Designate a meeting point outside (mailbox, tree) and call 911 from there."
        ]),
        SurvivalItem(id: 23, title: "Signal for Rescue", category: .urban, iconName: "antenna.radiowaves.left.and.right", isLocked: false, steps: [
            "Universal distress signal: 3 of anything — 3 whistles, 3 fires, 3 flashes of light.",
            "Use a whistle — it carries farther than your voice and requires less energy.",
            "At night, use a flashlight to signal SOS: 3 short, 3 long, 3 short flashes.",
            "Create ground signals visible from the air: use rocks or bright fabric to form an X or SOS.",
            "If near reflective material, use a signal mirror to flash sunlight toward aircraft.",
            "Stay in one place if possible — moving makes you harder to find."
        ]),
        SurvivalItem(id: 24, title: "Earthquake Protocol", category: .urban, iconName: "waveform.path.ecg", isLocked: false, steps: [
            "DROP to your hands and knees immediately — prevents being knocked down.",
            "Take COVER under a sturdy desk or table. Protect your head and neck with your arms.",
            "HOLD ON to your shelter and be ready to move with it until shaking stops.",
            "If no shelter is nearby, crouch by an interior wall away from windows and heavy objects.",
            "Do NOT run outside during the shaking — falling debris is the greatest danger.",
            "After the shaking stops: check for injuries, avoid damaged buildings, expect aftershocks."
        ]),
        SurvivalItem(id: 25, title: "Power Outage Kit", category: .urban, iconName: "powerplug.fill", isLocked: false, steps: [
            "Keep flashlights and extra batteries in an accessible location — avoid candles (fire risk).",
            "Store at least 1 gallon of water per person per day for a minimum of 3 days.",
            "Keep a battery-powered or hand-crank radio for emergency broadcasts.",
            "Fill freezer bags with water and freeze them — this keeps food cold longer and provides water.",
            "Charge devices: keep a portable power bank fully charged at all times.",
            "If power is out for 4+ hours, discard refrigerated perishable food to prevent illness."
        ]),
        SurvivalItem(id: 26, title: "Flood Survival", category: .urban, iconName: "cloud.heavyrain.fill", isLocked: false, steps: [
            "Move to higher ground immediately if flooding begins. Don't wait for instructions.",
            "Never walk through moving water — 6 inches can knock you down. Never drive through it.",
            "'Turn Around, Don't Drown' — just 12 inches of moving water can carry away a vehicle.",
            "If trapped in a building, go to the highest level. Do NOT go into an attic without roof access.",
            "Signal for help from a window or the roof. Call emergency services if you have cell signal.",
            "After flooding: avoid flood water (sewage, chemicals), check for structural damage before entering."
        ]),
        SurvivalItem(id: 27, title: "Gas Leak Response", category: .urban, iconName: "aqi.medium", isLocked: false, steps: [
            "Recognize signs: rotten egg smell, hissing near gas lines, dead plants near pipes, bubbles in water.",
            "Do NOT turn on/off any lights, switches, or appliances — sparks can ignite gas.",
            "Do NOT use your phone inside the building — go outside first.",
            "Open windows and doors as you exit to ventilate the area.",
            "Evacuate everyone immediately. Move at least 300 feet away from the building.",
            "Call your gas company's emergency line or 911 from a safe distance."
        ]),
        SurvivalItem(id: 28, title: "Self-Defense Basics", category: .urban, iconName: "hand.raised.fill", isLocked: false, steps: [
            "First priority: RUN. Escape the situation if at all possible.",
            "Second priority: create NOISE — yell 'FIRE' (more attention than 'HELP').",
            "Maintain distance and keep your hands up in a defensive stance.",
            "Target vulnerable areas if you must defend yourself: eyes, nose, throat, groin, knees.",
            "Use the palm heel strike (open hand, push from hip) — reduces risk of breaking your own hand.",
            "Break free from grabs: rotate your arm toward the attacker's thumb (the weakest point of grip)."
        ]),
        SurvivalItem(id: 29, title: "Navigate Without GPS", category: .urban, iconName: "map.fill", isLocked: false, steps: [
            "Use the sun: it rises in the East and sets in the West. At noon, shadows point roughly North (Northern Hemisphere).",
            "The 'watch method': point the hour hand at the sun. Halfway between it and 12 o'clock is South.",
            "At night: find the Big Dipper — the two stars at the end of the cup point to the North Star (Polaris).",
            "Moss tends to grow on the North side of trees (where there's less sun) — but this is unreliable alone.",
            "Use landmarks: rivers generally flow downhill to civilization. Follow them downstream.",
            "Leave markers (stacked rocks, broken branches) so you can retrace your route if needed."
        ]),
        SurvivalItem(id: 30, title: "Emergency Radio Use", category: .urban, iconName: "radio.fill", isLocked: false, steps: [
            "NOAA Weather Radio: tune to 162.400–162.550 MHz for official emergency broadcasts.",
            "Channel 9 on CB radio is the universal emergency/distress channel.",
            "For FRS/GMRS walkie-talkies: Channel 1 is commonly monitored for emergencies.",
            "Speak clearly: state your name, location, nature of emergency, and number of people involved.",
            "Use 'Mayday' (life-threatening) or 'Pan-Pan' (urgent but not life-threatening) to signal distress.",
            "Release the transmit button to listen for a response. Repeat your message every 2 minutes."
        ]),
        SurvivalItem(id: 51, title: "Lift Free Fall", category: .urban, iconName: "figure.fall", isLocked: false, steps: [
            "If the elevator suddenly drops, do NOT jump — you can't time it and landing wrong causes more injury.",
            "Lie flat on your back on the elevator floor — this distributes the impact force across your entire body.",
            "Cover your face and head with your arms to protect from falling ceiling panels and debris.",
            "If you can't lie down, crouch low with your knees bent and hold onto the handrail tightly.",
            "Brace for impact: the elevator's built-in shock absorbers and brakes will slow the fall significantly.",
            "After stopping: do NOT try to force doors open. Press the emergency button and wait for professional rescue."
        ]),
        SurvivalItem(id: 56, title: "Stop a Dog Attack", category: .urban, iconName: "xmark.shield.fill", isLocked: false, steps: [
            "Stand still like a tree — do NOT run. Running triggers a dog's chase instinct.",
            "Avoid direct eye contact (it's a challenge signal). Turn slightly sideways and stay calm.",
            "Place a barrier between you and the dog: backpack, jacket, purse, or bicycle.",
            "If knocked down: curl into a ball, protect your head and neck with your arms. Stay still and quiet.",
            "If the attack is severe and won't stop: fight back. Target the eyes, nose, and throat.",
            "After: wash wounds with soap and water immediately. Seek medical attention — dog bites carry high infection risk."
        ]),
        SurvivalItem(id: 57, title: "Lightning Safety", category: .urban, iconName: "bolt.fill", isLocked: false, steps: [
            "The 30/30 rule: if thunder follows lightning in under 30 seconds, seek shelter. Stay inside 30 min after the last strike.",
            "Go INDOORS to a substantial building or hard-topped vehicle. Avoid sheds, picnic shelters, and tents.",
            "If indoors: stay away from plumbing, wired electronics, and windows. Lightning travels through pipes and wires.",
            "If caught outside with no shelter: crouch low on the balls of your feet, feet together, arms wrapped around knees.",
            "Avoid: tall trees, open fields, hilltops, water, and metal objects (fences, poles, umbrellas).",
            "If someone is struck: call 911. It's safe to touch them — they carry no charge. Begin CPR if needed."
        ]),
        SurvivalItem(id: 58, title: "Carbon Monoxide Safety", category: .urban, iconName: "aqi.high", isLocked: false, steps: [
            "CO is invisible and odorless — install CO detectors on every level of your home. Test monthly.",
            "Symptoms: headache, dizziness, nausea, confusion, blurred vision — often mistaken for the flu.",
            "If the CO alarm sounds or you suspect CO: get everyone outside into fresh air IMMEDIATELY.",
            "Call 911 from outside. Do NOT re-enter the building until emergency services clear it.",
            "Never run generators, grills, or fuel-burning equipment indoors or in garages — even with doors open.",
            "In a power outage: never use a gas stove or oven to heat your home. Use battery-powered heaters only."
        ]),
        SurvivalItem(id: 59, title: "Hurricane Preparedness", category: .urban, iconName: "hurricane", isLocked: false, steps: [
            "Know your zone: check if you're in a hurricane evacuation zone. Have an evacuation route planned in advance.",
            "Build a Go-Kit: water (1 gal/person/day × 3 days), food, meds, documents, flashlight, battery radio, cash.",
            "Board up windows or install storm shutters. Bring outdoor furniture and loose objects inside.",
            "Fill bathtubs with water for flushing toilets. Charge all devices fully. Fill your car's gas tank.",
            "If ordered to evacuate: LEAVE immediately. Waiting creates deadly traffic jams and flood risk.",
            "If sheltering in place: stay in an interior room away from windows. Do NOT go outside during the eye — the storm resumes."
        ]),
        SurvivalItem(id: 60, title: "Wildfire Evacuation", category: .urban, iconName: "smoke.fill", isLocked: false, steps: [
            "If evacuation is ordered: LEAVE immediately. Wildfires can move faster than you can run.",
            "Grab your Go-Kit: IDs, meds, water, phone charger, cash. The 5 Ps: People, Prescriptions, Papers, Personal needs, Priceless items.",
            "Wear long sleeves, pants, boots, and a cotton mask or wet bandana to protect against smoke and embers.",
            "Drive with windows UP and air recirculation ON. Use headlights in smoky conditions. Drive slowly.",
            "If trapped by fire: call 911 with your location. Park away from vegetation, stay in your car with windows up.",
            "After: don't return until authorities say it's safe. Watch for hot spots, ash pits, and downed power lines."
        ]),
        
        // ─────────────────────────────────────────
        // WILD (31–40)
        // ─────────────────────────────────────────
        SurvivalItem(id: 31, title: "Build a Shelter", category: .wild, iconName: "house.fill", isLocked: false, steps: [
            "Choose a flat, dry area away from dead trees and potential flood paths. Start well before sunset.",
            "Build a debris hut: prop a ridge pole (body-length+) on a stump or Y-shaped sticks at 45°.",
            "Lean 'rib' sticks along both sides of the ridge pole, spaced 10–12 inches apart.",
            "Weave smaller sticks horizontally across the ribs to create a lattice framework.",
            "Pile at least 3 feet of leaves, ferns, moss, or pine needles on top for insulation.",
            "Fill the interior floor with 6+ inches of dry leaves for ground insulation. Stuff a leaf-filled shirt as a door plug."
        ]),
        SurvivalItem(id: 32, title: "Start Fire No Match", category: .wild, iconName: "flame.fill", isLocked: false, steps: [
            "Prepare your fire lay first: tinder (dry bark, cotton, char cloth), kindling (small sticks), fuel (larger wood).",
            "Bow drill method: carve a spindle and fireboard from dry softwood (willow, cedar, cottonwood).",
            "Make a bow from a curved stick and cordage. Wrap the string once around the spindle.",
            "Place the spindle on the fireboard notch. Press down with a bearing block and saw the bow back and forth.",
            "Friction creates a hot ember in the notch. Carefully transfer the ember to your tinder bundle.",
            "Blow gently on the tinder bundle until it ignites. Place it in your fire lay and add kindling gradually."
        ]),
        SurvivalItem(id: 33, title: "Purify Water", category: .wild, iconName: "drop.fill", isLocked: false, steps: [
            "Assume ALL natural water is contaminated — even clear streams can harbor parasites.",
            "Boiling: bring water to a rolling boil for at least 1 minute (3 minutes above 6,500 ft elevation).",
            "Pre-filter cloudy water through a cloth or shirt to remove sediment before purifying.",
            "Chemical method: 2 drops of unscented household bleach per liter, stir, wait 30 minutes.",
            "Solar method (SODIS): fill clear plastic bottles, lay in direct sunlight for 6+ hours.",
            "DIY filter: layer gravel, sand, and crushed charcoal in a container — then still boil the filtered water."
        ]),
        SurvivalItem(id: 34, title: "Identify Edible Plants", category: .wild, iconName: "leaf.arrow.circlepath", isLocked: false, steps: [
            "Golden rule: if you can't 100% identify it, DO NOT eat it. Many toxic plants look edible.",
            "Universal Edibility Test: rub the plant on your wrist. Wait 15 min. No reaction? Try your lip.",
            "Wait another 15 min. No burning or numbness? Place a small piece on your tongue for 15 min.",
            "If still no reaction, chew a small amount but don't swallow. Wait 15 min for effects.",
            "Safe bets in most regions: dandelions (all parts), cattails (shoots/roots), clover, plantain weed.",
            "AVOID: white berries (almost always toxic), mushrooms (unless expert), and plants with milky sap."
        ]),
        SurvivalItem(id: 35, title: "Navigate by Stars", category: .wild, iconName: "star.fill", isLocked: false, steps: [
            "Northern Hemisphere: find the Big Dipper. The two stars at the cup's end point to the North Star (Polaris).",
            "Polaris sits nearly directly above the North Pole — it always indicates true North.",
            "Southern Hemisphere: find the Southern Cross. Extend the long axis 4.5× its length downward to find South.",
            "Orion's Belt rises in the East and sets in the West — useful anywhere on Earth for East/West direction.",
            "Two-stick method: place two sticks in the ground. Align a star with both tips. Watch the star drift to determine cardinal direction.",
            "Stars move East to West. If a star rises, you're facing East. If it falls, you're facing West."
        ]),
        SurvivalItem(id: 36, title: "Set a Snare Trap", category: .wild, iconName: "circle.dashed", isLocked: false, steps: [
            "Use this knowledge only in genuine survival situations — trapping is regulated by law.",
            "Find an active game trail: look for tracks, droppings, and worn paths in vegetation.",
            "Make a simple loop snare from wire, paracord, or strong twine.",
            "Create a loop about fist-sized for rabbits, larger for bigger game.",
            "Secure the snare to a sturdy stake or tree. Position the loop at head height of your target animal.",
            "Set multiple snares on different trails. Check them every few hours to prevent animal suffering."
        ]),
        SurvivalItem(id: 37, title: "Cross a River", category: .wild, iconName: "water.waves", isLocked: false, steps: [
            "Scout the river first: look for the widest, most shallow section — fast narrow water is deepest.",
            "Never cross in water above your waist — even knee-deep fast water can sweep you away.",
            "Remove socks but keep shoes on for grip. Unbuckle your pack's waist strap in case you fall.",
            "Use a sturdy stick or trekking pole upstream as a third point of contact.",
            "Face upstream and move diagonally with the current, shuffling your feet — never cross them.",
            "If swept away: float on your back, feet downstream, and angle toward shore."
        ]),
        SurvivalItem(id: 38, title: "Bear Encounter", category: .wild, iconName: "pawprint.fill", isLocked: false, steps: [
            "Stay calm. Do NOT run — bears can sprint 35 mph. Running triggers their chase instinct.",
            "Make yourself appear large. Speak calmly so the bear recognizes you as human, not prey.",
            "Back away slowly and sideways. Avoid direct eye contact (it's a challenge signal).",
            "If a GRIZZLY attacks: PLAY DEAD. Lie on your stomach, hands behind your neck, legs spread.",
            "If a BLACK BEAR attacks: FIGHT BACK. Hit the face and muzzle with everything you have.",
            "Carry bear spray in bear country and know how to deploy it — aim low, spray in a wide arc at 20 ft."
        ]),
        SurvivalItem(id: 39, title: "Signal with Mirror", category: .wild, iconName: "sun.max.fill", isLocked: false, steps: [
            "Any reflective surface works: mirror, phone screen, foil, even a polished can lid.",
            "Hold the mirror close to your face and reflect sunlight onto your other hand.",
            "Extend your free hand toward the target (aircraft, boat, rescuers) and make a V with two fingers.",
            "Tilt the mirror until the reflected light hits your fingers — the beam is now aimed at the target.",
            "Flash the light back and forth in groups of three (SOS) to signal distress.",
            "A mirror signal can be seen for 50+ miles on a clear day — far beyond any other visual signal."
        ]),
        SurvivalItem(id: 40, title: "Tie Survival Knots", category: .wild, iconName: "link.circle.fill", isLocked: false, steps: [
            "Bowline ('king of knots'): creates a fixed loop that won't slip. Used for rescue and securing loads.",
            "Form a small loop. Pass the end up through it, around the standing line, and back down through the loop.",
            "Clove Hitch: quick, adjustable knot for tying to trees or poles. Two loops over the object, tuck the end.",
            "Taut-Line Hitch: adjustable tension knot perfect for tent guy lines — slides to tighten, holds under load.",
            "Figure-Eight Knot: stopper knot that prevents rope from slipping through. Used in climbing and rescue.",
            "Square Knot (Reef Knot): joins two ropes of equal thickness. Right over left, then left over right."
        ]),
        SurvivalItem(id: 61, title: "Escape Rip Current", category: .wild, iconName: "water.waves", isLocked: false, steps: [
            "Stay CALM — a rip current pulls you OUT, not UNDER. Panicking and fighting it causes drowning.",
            "Do NOT swim directly back to shore against the current — you will exhaust yourself.",
            "Swim PARALLEL to the shoreline. Rip currents are narrow — swimming sideways escapes the pull.",
            "If you can't swim out: float or tread water. Most rip currents weaken 50–100 yards offshore.",
            "Once free of the current, swim diagonally back to shore at an angle away from the rip.",
            "Signal for help: raise one arm and shout. If helping someone else, throw them a flotation device — do NOT swim to them."
        ]),
        SurvivalItem(id: 62, title: "Avalanche Survival", category: .wild, iconName: "cloud.snow.fill", isLocked: false, steps: [
            "If caught in an avalanche: try to move to the side — avalanches are narrower than they appear.",
            "Grab onto a tree or rock if possible. Drop heavy gear like your backpack.",
            "If swept up: 'swim' vigorously with backstroke motions to stay near the surface.",
            "As the snow slows, create an air pocket: cup your hands over your mouth and nose before it sets.",
            "Once the snow stops, try to determine which way is up (let saliva drip — gravity tells you). Dig upward.",
            "If buried: stay calm, breathe slowly to conserve oxygen. Shout only when you hear rescuers nearby — snow muffles sound."
        ]),
        
        // ─────────────────────────────────────────
        // TOOLS (41–50)
        // ─────────────────────────────────────────
        SurvivalItem(id: 41, title: "Make a Torch", category: .tools, iconName: "flashlight.on.fill", isLocked: false, steps: [
            "Find a sturdy stick (2–3 ft) and wrap one end with cloth, cotton, or dry bark strips.",
            "If available, soak the wrapped end in tree resin, animal fat, or a small amount of fuel for longer burn time.",
            "Secure the wrapping tightly with cord, wire, or strips of cloth so it doesn't unravel.",
            "Light the torch from an existing fire or matches. Hold at arm's length — away from your face.",
            "A well-made torch burns for 20–45 minutes. Tilt slightly downward so flames don't reach your hand.",
            "Improvised alternative: stuff a tin can with cloth wicks and add cooking oil for a longer-lasting lantern."
        ]),
        SurvivalItem(id: 42, title: "Tarp Shelter Setup", category: .tools, iconName: "tent.fill", isLocked: false, steps: [
            "A-frame: run a rope between two trees at waist height. Drape the tarp over it and stake the edges.",
            "Lean-to: tie one edge of the tarp to a horizontal rope or branch. Stake the opposite edge to the ground at an angle.",
            "Angle the shelter AWAY from wind. Position the opening downwind for maximum protection.",
            "Use rocks, logs, or packed dirt if you don't have stakes — weight the edges down securely.",
            "Tension is key: pull the tarp tight to prevent flapping and water pooling. Create a slight slope for rain runoff.",
            "Ground cover: place leaves, pine needles, or a second tarp on the ground inside to insulate from cold and wet soil."
        ]),

        SurvivalItem(id: 45, title: "DIY Water Filter", category: .tools, iconName: "line.3.horizontal.decrease.circle.fill", isLocked: false, steps: [
            "Cut the bottom off a plastic bottle. Turn it upside down to use as a funnel.",
            "Place a clean cloth or coffee filter at the neck opening to catch fine particles.",
            "Add a layer of crushed charcoal (from a dead campfire) — this absorbs chemicals and improves taste.",
            "Add a layer of fine sand above the charcoal, then coarse sand, then small gravel at the top.",
            "Pour water in slowly at the top. Collect filtered water from the bottom into a clean container.",
            "IMPORTANT: this removes sediment and some chemicals, but you MUST still boil or chemically treat the filtered water."
        ]),
        SurvivalItem(id: 46, title: "Improvised Compass", category: .tools, iconName: "location.north.fill", isLocked: false, steps: [
            "Find a needle, pin, razor blade, or any small piece of steel.",
            "Magnetize it by stroking it in ONE direction (50+ times) with a magnet, silk, or against your hair.",
            "Place a small leaf or piece of bark on the surface of still water.",
            "Carefully lay the magnetized needle on the floating leaf.",
            "The needle will slowly rotate to align with Earth's magnetic field — pointing North/South.",
            "Identify which end is North using the sun's position (rises East, sets West) to calibrate."
        ]),

        SurvivalItem(id: 49, title: "Emergency Whistle", category: .tools, iconName: "speaker.wave.3.fill", isLocked: false, steps: [
            "If you don't have a whistle, improvise: an acorn cap, bottle cap, or your cupped hands can work.",
            "Acorn cap whistle: hold the cap dome-up between your thumbs. Press your lips to your thumb knuckles and blow.",
            "Hand whistle: cup your hands together, leave a small gap at your thumb joints, and blow across the opening.",
            "Distress signal: blow 3 short, sharp blasts — the international signal for 'I need help.'",
            "Repeat every 1–2 minutes. A whistle carries up to 1 mile — far more than shouting.",
            "Always carry a whistle on your backpack or keychain when outdoors. They weigh almost nothing."
        ]),
        SurvivalItem(id: 63, title: "Collect Rainwater", category: .tools, iconName: "cloud.rain.fill", isLocked: false, steps: [
            "Use ANY container: pots, buckets, tarps, plastic bags, even a hollowed log or large leaves.",
            "Spread a tarp or poncho at an angle to funnel rain into a container at the lowest point.",
            "Tie the corners of a tarp to trees and place a stone in the center to create a natural funnel.",
            "Collect dew at dawn: drag a cloth or t-shirt through tall grass, then wring it into a container.",
            "In tropical areas: cut a banana tree stump — the hollow fills with drinkable water within hours.",
            "Always filter and purify collected rainwater if possible — bird droppings and debris carry bacteria."
        ]),
        SurvivalItem(id: 64, title: "Build Emergency Kit", category: .tools, iconName: "cross.case.fill", isLocked: false, steps: [
            "Water: 1 gallon per person per day for at least 3 days. Store in clean, food-grade containers.",
            "Food: 3-day supply of non-perishable items (canned goods, energy bars, dried fruit, peanut butter).",
            "First aid: bandages, gauze, antiseptic, pain relievers, prescription meds (7-day supply), tweezers.",
            "Tools: flashlight + extra batteries, battery/crank radio, whistle, multi-tool, duct tape, manual can opener.",
            "Documents: copies of IDs, insurance, bank info in a waterproof bag. Cash in small bills.",
            "Extras: phone charger/power bank, blankets, rain poncho, N95 masks, local maps, pen and paper."
        ]),
        SurvivalItem(id: 65, title: "Survival Hygiene", category: .tools, iconName: "leaf.fill", isLocked: false, steps: [
            "Hand hygiene prevents deadly infections: wash with soap and water, or use hand sanitizer (60%+ alcohol).",
            "Oral care: chew on a fibrous twig (like willow or birch) to clean teeth. Rinse mouth with clean water.",
            "Waste disposal: dig a 'cat hole' 6–8 inches deep, at least 200 feet from water sources and camp.",
            "Keep wounds clean: wash daily with clean water, reapply bandaging, and watch for signs of infection.",
            "Change socks daily if possible — wet feet lead to trench foot. Dry feet and socks by fire or in the sun.",
            "Boil or sanitize shared utensils. In a group, isolate anyone showing signs of contagious illness."
        ]),
    ]
    
    /// Efficient O(1) lookup by category using lazy dictionary grouping.
    /// Computed once, cached in a static let for zero repeated allocation.
    static let byCategory: [SurvivalCategory: [SurvivalItem]] = {
        Dictionary(grouping: items, by: \.category)
    }()
    
    /// Retrieve items for a specific category, or all items if nil.
    static func items(for category: SurvivalCategory?) -> [SurvivalItem] {
        guard let category else { return items }
        return byCategory[category] ?? []
    }
}
