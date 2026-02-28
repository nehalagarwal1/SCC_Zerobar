import SwiftUI

// MARK: - Scene Illustrations
// This file contains all the bespoke, highly-detailed micro-scenes for every single item.
// Each view is tailored to accurately depict the specific action required in that step.

struct IllustrationProvider {
    @ViewBuilder
    static func illustration(for item: SurvivalItem, step: Int, color: Color) -> some View {
        switch item.id {
        // MEDICAL
        case 1:  CPRIllustration(step: step, color: color)
        case 2:  BleedingIllustration(step: step, color: color)
        case 3:  BurnIllustration(step: step, color: color)
        case 4:  FractureIllustration(step: step, color: color)
        case 5:  HeimlichIllustration(step: step, color: color)
        case 6:  HypothermiaIllustration(step: step, color: color)
        case 7:  SnakeBiteIllustration(step: step, color: color)
        case 8:  AllergyIllustration(step: step, color: color)
        case 9:  DehydrationIllustration(step: step, color: color)
        case 10: ImprovisedStretcherIllustration(step: step, color: color)
        case 52: HeatStrokeIllustration(step: step, color: color)
        case 53: StrokeIllustration(step: step, color: color)
        case 54: InsectStingIllustration(step: step, color: color)
        case 55: RecoveryPositionIllustration(step: step, color: color)
        // AUTO
        case 11: TireChangeIllustration(step: step, color: color)
        case 12: JumpStartIllustration(step: step, color: color)
        case 13: EscapeSinkingCarIllustration(step: step, color: color)
        case 14: EngineOverheatIllustration(step: step, color: color)
        case 15: PatchRadiatorHoseIllustration(step: step, color: color)
        case 16: CarStuckInSnowIllustration(step: step, color: color)
        case 17: TowWithRopeIllustration(step: step, color: color)
        case 18: CarAccidentResponseIllustration(step: step, color: color)
        case 19: EmergencyBrakeFixIllustration(step: step, color: color)
        case 20: RoadsideBreakdownIllustration(step: step, color: color)
        // URBAN
        case 21: TornadoProtocolIllustration(step: step, color: color)
        case 22: FireEscapePlanIllustration(step: step, color: color)
        case 23: SignalForRescueIllustration(step: step, color: color)
        case 24: EarthquakeProtocolIllustration(step: step, color: color)
        case 25: PowerOutageKitIllustration(step: step, color: color)
        case 26: FloodSurvivalIllustration(step: step, color: color)
        case 27: GasLeakResponseIllustration(step: step, color: color)
        case 28: SelfDefenseBasicsIllustration(step: step, color: color)
        case 29: NavigateWithoutGPSIllustration(step: step, color: color)
        case 30: EmergencyRadioUseIllustration(step: step, color: color)
        case 51: LiftFreeFallIllustration(step: step, color: color)
        case 56: StopDogAttackIllustration(step: step, color: color)
        case 57: LightningSafetyIllustration(step: step, color: color)
        case 58: CarbonMonoxideSafetyIllustration(step: step, color: color)
        case 59: HurricanePreparednessIllustration(step: step, color: color)
        case 60: WildfireEvacuationIllustration(step: step, color: color)
        // WILD
        case 31: BuildShelterIllustration(step: step, color: color)
        case 32: StartFireNoMatchIllustration(step: step, color: color)
        case 33: PurifyWaterIllustration(step: step, color: color)
        case 34: IdentifyEdiblePlantsIllustration(step: step, color: color)
        case 35: NavigateByStarsIllustration(step: step, color: color)
        case 36: SetSnareTrapIllustration(step: step, color: color)
        case 37: CrossRiverIllustration(step: step, color: color)
        case 38: BearEncounterIllustration(step: step, color: color)
        case 39: SignalWithMirrorIllustration(step: step, color: color)
        case 40: TieSurvivalKnotsIllustration(step: step, color: color)
        case 61: EscapeRipCurrentIllustration(step: step, color: color)
        case 62: AvalancheSurvivalIllustration(step: step, color: color)
        // TOOLS
        case 41: MakeTorchIllustration(step: step, color: color)
        case 42: TarpShelterSetupIllustration(step: step, color: color)
        case 45: DIYWaterFilterIllustration(step: step, color: color)
        case 46: ImprovisedCompassIllustration(step: step, color: color)
        case 49: EmergencyWhistleIllustration(step: step, color: color)
        case 63: CollectRainwaterIllustration(step: step, color: color)
        case 64: BuildEmergencyKitIllustration(step: step, color: color)
        case 65: SurvivalHygieneIllustration(step: step, color: color)
        
        default: DefaultIllustration(iconName: StepIconMapper.icon(for: item.steps[step]), color: color)
        }
    }
}

// MARK: - Default Illustration
struct DefaultIllustration: View {
    let iconName: String
    let color: Color
    @State private var pulse = false
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 80, weight: .light))
            .foregroundStyle(color)
            .scaleEffect(pulse ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

// MARK: - Medical Illustrations (1-10, 52-55)

struct CPRIllustration: View {
    let step: Int
    let color: Color
    // Implement steps based on CPR text
    var body: some View {
        VStack {
             if step == 0 {
                 // Check the scene for safety and call for help.
                 Image(systemName: "phone.fill.arrow.up.right")
             } else if step == 1 {
                 // Place the heel of your hand on the center of the chest.
                 Image(systemName: "hand.raised.fill")
             } else if step == 2 {
                 // Push hard and fast — 2 inches deep, 100–120 BPM.
                 Image(systemName: "heart.fill")
             } else if step == 3 {
                 // After 30 compressions, give 2 rescue breaths.
                 Image(systemName: "lungs.fill")
             } else {
                 // Continue until help arrives or an AED is available.
                 Image(systemName: "cross.case.fill")
             }
        }
        .font(.system(size: 80, weight: .light))
        .foregroundStyle(color)
    }
}

struct BleedingIllustration: View {
    let step: Int
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
            // Draw standard wound representation
            var woundPath = Path()
            woundPath.addEllipse(in: CGRect(x: center.x - 30, y: center.y - 10, width: 60, height: 20))
            context.fill(woundPath, with: .color(color.opacity(0.3)))
            context.stroke(woundPath, with: .color(color), lineWidth: 2)
            
            // Step 0: Put on gloves
            if step == 0 {
                var glovesPath = Path()
                glovesPath.addRoundedRect(in: CGRect(x: center.x - 20, y: center.y - 40, width: 40, height: 40), cornerSize: CGSize(width: 5, height: 5))
                context.fill(glovesPath, with: .color(.white))
                context.stroke(glovesPath, with: .color(.gray), lineWidth: 2)
            }
            // Step 1: Apply pressure
            else if step == 1 {
                var gauzePath = Path()
                gauzePath.addRoundedRect(in: CGRect(x: center.x - 40, y: center.y - 30, width: 80, height: 60), cornerSize: CGSize(width: 8, height: 8))
                context.fill(gauzePath, with: .color(.white.opacity(0.9)))
                context.stroke(gauzePath, with: .color(.gray.opacity(0.5)), lineWidth: 1)
            }
            // Step 2: Add more layers
            else if step == 2 {
                for i in 0..<3 {
                    var gauzePath = Path()
                    gauzePath.addRoundedRect(in: CGRect(x: center.x - 40, y: center.y - 30 - CGFloat(i*5), width: 80, height: 60), cornerSize: CGSize(width: 8, height: 8))
                    context.fill(gauzePath, with: .color(.white.opacity(0.9)))
                    context.stroke(gauzePath, with: .color(.gray.opacity(0.5)), lineWidth: 1)
                }
            }
            // Step 3: Elevate
            else if step == 3 {
                 Image(systemName: "arrow.up").font(.largeTitle)
            }
            // Step 4: Maintain steady pressure
            else if step == 4 {
                var gauzePath = Path()
                gauzePath.addRoundedRect(in: CGRect(x: center.x - 40, y: center.y - 30, width: 80, height: 60), cornerSize: CGSize(width: 8, height: 8))
                context.fill(gauzePath, with: .color(.white.opacity(0.9)))
                context.stroke(gauzePath, with: .color(.gray.opacity(0.5)), lineWidth: 1)
                 // Add an arrow pressing down
            }
            // Step 5: Tourniquet
            else if step >= 5 {
                var tourniquetPath = Path()
                tourniquetPath.addRect(CGRect(x: center.x - 50, y: center.y - 50, width: 100, height: 15))
                context.fill(tourniquetPath, with: .color(.black))
                context.stroke(tourniquetPath, with: .color(color), lineWidth: 2)
                 
                 var woundPath = Path()
                 woundPath.addEllipse(in: CGRect(x: center.x - 30, y: center.y + 20, width: 60, height: 20))
                 context.fill(woundPath, with: .color(color.opacity(0.3)))
                 context.stroke(woundPath, with: .color(color), lineWidth: 2)
            }
        }
        .frame(width: 150, height: 150)
    }
}

struct BurnIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                HStack(spacing: 20) {
                    Image(systemName: "flame.fill").foregroundColor(.red).font(.system(size: 60))
                    Image(systemName: "arrow.right").foregroundColor(color)
                    Image(systemName: "figure.walk").foregroundColor(color)
                }
            } else if step == 1 {
                VStack {
                    Image(systemName: "drop.fill").foregroundColor(.blue).offset(y: 10)
                    Image(systemName: "drop.fill").foregroundColor(.blue)
                    RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.5)).frame(width: 80, height: 20)
                }
            } else if step == 2 {
                ZStack {
                    Image(systemName: "snowflake").font(.system(size: 60))
                    Image(systemName: "slash.circle").foregroundColor(.red).font(.system(size: 80))
                }
            } else if step == 3 {
                Image(systemName: "watch").foregroundColor(.gray).opacity(0.5)
                Image(systemName: "arrow.up.right")
            } else if step == 4 {
                RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2, dash: [5])).frame(width: 80, height: 40).foregroundColor(color)
                Image(systemName: "bandage.fill").foregroundColor(color)
            } else {
                Image(systemName: "cross.case.fill").foregroundColor(.red)
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct FractureIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "bone").rotationEffect(.degrees(45))
                Image(systemName: "waveform.path.ecg").foregroundColor(.red)
            } else if step == 1 {
                Image(systemName: "bone").rotationEffect(.degrees(45))
                Image(systemName: "lock.fill").offset(x: 30, y: -30)
            } else if step == 2 {
                HStack(spacing: 5) {
                    Rectangle().frame(width: 10, height: 80)
                    Image(systemName: "bone").rotationEffect(.degrees(45))
                    Rectangle().frame(width: 10, height: 80)
                }
            } else if step == 3 {
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(color.opacity(0.3)).frame(width: 60, height: 100)
                    Image(systemName: "bone").rotationEffect(.degrees(45))
                }
            } else if step == 4 {
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(color.opacity(0.3)).frame(width: 60, height: 100)
                    Image(systemName: "bone").rotationEffect(.degrees(45))
                    VStack(spacing: 20) {
                        Rectangle().fill(color).frame(width: 70, height: 10)
                        Rectangle().fill(color).frame(width: 70, height: 10)
                    }
                }
            } else {
                Image(systemName: "hand.raised.fill")
                Image(systemName: "waveform.path.ecg").foregroundColor(.red).offset(y: 40)
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct HeimlichIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "person.fill.questionmark")
            } else if step == 1 {
                HStack {
                    Image(systemName: "person.fill")
                    Image(systemName: "hand.raised.fill").rotationEffect(.degrees(-45))
                }
            } else if step == 2 {
                HStack(spacing: -10) {
                    Image(systemName: "figure.arms.open")
                    Image(systemName: "person.fill")
                }
            } else if step == 3 {
                Image(systemName: "hand.raised.square.fill")
            } else if step == 4 {
                Image(systemName: "arrow.up.right.circle.fill")
            } else {
                HStack {
                    Image(systemName: "person.fill")
                    Image(systemName: "circle.fill").font(.system(size: 20)).offset(x: 20, y: -20)
                }
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct HypothermiaIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "house.fill")
                Image(systemName: "thermometer.sun.fill").offset(x: 30, y: 30)
            } else if step == 1 {
                Image(systemName: "tshirt.fill")
                Image(systemName: "drop.fill").foregroundColor(.blue).offset(x: 20, y: 20)
                Image(systemName: "slash.circle.fill").foregroundColor(.red).font(.system(size: 80))
            } else if step == 2 {
                Image(systemName: "figure.stand")
                Circle().fill(Color.orange.opacity(0.6)).frame(width: 30, height: 30).offset(y: -10)
            } else if step == 3 {
                HStack(spacing: -10) {
                    Image(systemName: "figure.stand")
                    Image(systemName: "figure.stand")
                }
            } else if step == 4 {
                Image(systemName: "cup.and.saucer.fill")
            } else {
                Image(systemName: "hands.sparkles.fill")
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct SnakeBiteIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                HStack {
                    Image(systemName: "figure.walk")
                    Image(systemName: "arrow.right")
                    Image(systemName: "lizard.fill").rotationEffect(.degrees(180))
                }
            } else if step == 1 {
                Image(systemName: "figure.stand")
                Image(systemName: "minus.circle").offset(x: 30, y: -30)
            } else if step == 2 {
                Image(systemName: "watch")
                Image(systemName: "arrow.up.right").offset(x: 20, y: -20)
            } else if step == 3 {
                HStack {
                    Image(systemName: "bolt.heart.fill").foregroundColor(.red)
                    Image(systemName: "arrow.down")
                    Image(systemName: "hand.raised.fill")
                }
            } else if step == 4 {
                Image(systemName: "cross.vial.fill")
                Image(systemName: "slash.circle.fill").foregroundColor(.red).font(.system(size: 80))
            } else {
                Image(systemName: "phone.fill.arrow.up.right")
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct AllergyIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "face.dashed")
            } else if step == 1 {
                Image(systemName: "phone.fill.arrow.up.right")
            } else if step == 2 {
                Image(systemName: "syringe.fill")
                Image(systemName: "arrow.down.right").offset(x: 20, y: 20)
            } else if step == 3 {
                Image(systemName: "timer")
                Text("10s").font(.caption).bold().offset(y: 35)
            } else if step == 4 {
                HStack {
                    Image(systemName: "figure.stand").rotationEffect(.degrees(90))
                    Image(systemName: "arrow.up")
                }
            } else {
                Image(systemName: "syringe.fill")
                Text("x2").font(.title).bold().offset(x: 30, y: 30)
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct DehydrationIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "drop.triangle.fill")
            } else if step == 1 {
                Image(systemName: "tree.fill")
                Image(systemName: "cloud.sun.fill").offset(x: -30, y: -30)
            } else if step == 2 {
                HStack {
                    Image(systemName: "drop.fill")
                    Image(systemName: "drop.fill")
                    Image(systemName: "drop.fill")
                }
            } else if step == 3 {
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
            } else if step == 4 {
                Image(systemName: "cup.and.saucer.fill")
                Image(systemName: "slash.circle.fill").foregroundColor(.red).font(.system(size: 80))
            } else {
                Image(systemName: "cross.case.fill")
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct ImprovisedStretcherIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                HStack {
                    Rectangle().frame(width: 5, height: 80)
                    Rectangle().frame(width: 5, height: 80)
                }
            } else if step == 1 {
                ZStack {
                    Rectangle().fill(color.opacity(0.3)).frame(width: 60, height: 80)
                    HStack {
                        Rectangle().fill(color).frame(width: 5, height: 90)
                        Spacer().frame(width: 40)
                        Rectangle().fill(color).frame(width: 5, height: 90)
                    }
                }
            } else if step == 2 {
                Image(systemName: "tshirt.fill").font(.system(size: 80))
                HStack {
                    Rectangle().fill(color).frame(width: 5, height: 90).offset(x: -15)
                    Spacer().frame(width: 0)
                    Rectangle().fill(color).frame(width: 5, height: 90).offset(x: 15)
                }
            } else if step == 3 {
                Image(systemName: "paperclip")
            } else if step == 4 {
                Image(systemName: "scalemass.fill")
            } else {
                HStack {
                    Image(systemName: "figure.walk")
                    Image(systemName: "bed.double.fill")
                    Image(systemName: "figure.walk")
                }
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct HeatStrokeIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "thermometer.sun.fill")
                Text("103°").font(.caption).bold().offset(x: 30, y: -30)
            } else if step == 1 {
                Image(systemName: "snowflake.circle.fill")
            } else if step == 2 {
                Image(systemName: "bathtub.fill").foregroundColor(.blue)
            } else if step == 3 {
                Image(systemName: "snowflake")
                Image(systemName: "person.fill").opacity(0.5)
            } else if step == 4 {
                Image(systemName: "wind")
            } else {
                Image(systemName: "drop.fill")
                Image(systemName: "slash.circle.fill").foregroundColor(.red).font(.system(size: 80))
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct StrokeIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Text("BE\nFAST").font(.title).bold().multilineTextAlignment(.center)
            } else if step == 1 {
                Image(systemName: "face.smiling.inverse")
            } else if step == 2 {
                Image(systemName: "figure.arms.open")
            } else if step == 3 {
                Image(systemName: "waveform")
            } else if step == 4 {
                Image(systemName: "clock.fill")
            } else {
                Image(systemName: "cross.case.fill")
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct InsectStingIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "creditcard.fill")
                Image(systemName: "arrow.left.and.right").offset(y: 30)
            } else if step == 1 {
                Image(systemName: "bubbles.and.sparkles.fill")
            } else if step == 2 {
                Image(systemName: "pills.fill")
            } else if step == 3 {
                Image(systemName: "lungs.fill")
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red).offset(x: 20, y: -20)
            } else if step == 4 {
                Image(systemName: "ant.fill") // Using ant since no spider symbol
                Image(systemName: "cross.case.fill").offset(x: 20, y: -20)
            } else {
                Image(systemName: "shield.checkered")
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct RecoveryPositionIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 {
                Image(systemName: "lungs.fill").foregroundColor(.blue)
            } else if step == 1 {
                Image(systemName: "figure.walk.arms.open")
            } else if step == 2 {
                Image(systemName: "hand.raised.fill").rotationEffect(.degrees(90))
            } else if step == 3 {
                Image(systemName: "figure.run")
            } else if step == 4 {
                Image(systemName: "figure.roll") // conceptual
            } else {
                Image(systemName: "head.profile.arrow.forward.and.vision")
            }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

// AUTO
struct TireChangeIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "parkingsign.circle.fill"); Image(systemName: "car.side.fill") } }
            else if step == 1 { Image(systemName: "arrow.down.to.line") }
            else if step == 2 { Image(systemName: "arrow.up.square.fill") }
            else if step == 3 { HStack { Image(systemName: "circle.dashed"); Image(systemName: "wrench.adjustable.fill") } }
            else if step == 4 { Image(systemName: "star.fill") }
            else { HStack { Image(systemName: "arrow.down.square.fill"); Image(systemName: "wrench.adjustable.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct JumpStartIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "car.2.fill") }
            else if step == 1 { HStack { Image(systemName: "bolt.batteryblock.fill").foregroundColor(.red); Image(systemName: "plus.circle.fill") } }
            else if step == 2 { HStack { Image(systemName: "battery.100.bolt").foregroundColor(.green); Image(systemName: "plus.circle.fill") } }
            else if step == 3 { HStack { Image(systemName: "battery.100.bolt").foregroundColor(.green); Image(systemName: "minus.circle.fill") } }
            else if step == 4 { HStack { Image(systemName: "minus.circle.fill"); Image(systemName: "engine.combustion.fill") } }
            else if step == 5 { HStack { Image(systemName: "key.fill"); Image(systemName: "timer") } }
            else { Image(systemName: "arrow.uturn.backward.circle.fill") }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EscapeSinkingCarIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "water.waves"); Image(systemName: "timer") } }
            else if step == 1 { Image(systemName: "figure.seated.seatbelt.and.airbag.on").rotationEffect(.degrees(10)) } // seatbelt off concept
            else if step == 2 { HStack { Image(systemName: "car.door.left.fill"); Image(systemName: "xmark.circle.fill").foregroundColor(.red) } }
            else if step == 3 { Image(systemName: "rectangle.portrait.bottomhalf.inset.filled") }
            else if step == 4 { HStack { Image(systemName: "hammer.fill"); Image(systemName: "rectangle.dashed") } }
            else { HStack { Image(systemName: "figure.pool.swim"); Image(systemName: "arrow.up") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EngineOverheatIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "snowflake.slash"); Image(systemName: "flame.fill").foregroundColor(.red) } }
            else if step == 1 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "stop.circle.fill").foregroundColor(.red) } }
            else if step == 2 { HStack { Image(systemName: "timer"); Text("30m").font(.title).bold() } }
            else if step == 3 { Image(systemName: "drop.fill").foregroundColor(.blue) }
            else if step == 4 { HStack { Image(systemName: "magnifyingglass"); Image(systemName: "drop.fill").foregroundColor(.green) } }
            else { HStack { Image(systemName: "car.side.fill"); Image(systemName: "tortoise.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct PatchRadiatorHoseIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "thermometer.snowflake") }
            else if step == 1 { HStack { Image(systemName: "magnifyingglass"); Image(systemName: "drop.fill") } }
            else if step == 2 { Image(systemName: "sparkles") }
            else if step == 3 { Image(systemName: "rectangle.fill").foregroundColor(.gray) } // tape
            else if step == 4 { Image(systemName: "rectangle.stack.fill").foregroundColor(.gray) }
            else { HStack { Image(systemName: "drop.fill"); Image(systemName: "wrench.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct CarStuckInSnowIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "circle.dashed"); Image(systemName: "xmark.circle.fill").foregroundColor(.red) } }
            else if step == 1 { Image(systemName: "snowflake.slash") }
            else if step == 2 { Image(systemName: "squareshape.split.3x3") } // traction concept
            else if step == 3 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "arrow.left.and.right") } }
            else if step == 4 { HStack { Image(systemName: "tire"); Image(systemName: "arrow.down") } }
            else { HStack { Image(systemName: "figure.walk"); Image(systemName: "car.side.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct TowWithRopeIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "link") }
            else if step == 1 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "link"); Image(systemName: "car.side.fill") } }
            else if step == 2 { Image(systemName: "minus").font(.system(size: 100, weight: .heavy)) } // taut line
            else if step == 3 { Image(systemName: "key.fill") }
            else if step == 4 { HStack { Image(systemName: "tortoise.fill"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } }
            else { HStack { Image(systemName: "car.side.fill"); Image(systemName: "arrow.down.to.line") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct CarAccidentResponseIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "parkingsign.circle.fill"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } }
            else if step == 1 { Image(systemName: "phone.fill.arrow.up.right").foregroundColor(.red) }
            else if step == 2 { Image(systemName: "person.2.fill") }
            else if step == 3 { Image(systemName: "cross.case.fill").foregroundColor(.red) }
            else if step == 4 { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) }
            else { Image(systemName: "doc.text.fill") }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EmergencyBrakeFixIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red); Image(systemName: "shoe.fill") } }
            else if step == 1 { HStack { Image(systemName: "shoe.fill"); Image(systemName: "arrow.up.and.down") } }
            else if step == 2 { HStack { Image(systemName: "arrow.down"); Image(systemName: "gearshape.fill") } }
            else if step == 3 { Image(systemName: "parkingsign.circle.fill").foregroundColor(.red) }
            else if step == 4 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "triangle.fill").rotationEffect(.degrees(90)).opacity(0.5) } }
            else { HStack { Image(systemName: "stop.circle.fill").foregroundColor(.red); Image(systemName: "phone.fill.arrow.up.right") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct RoadsideBreakdownIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } }
            else if step == 1 { Image(systemName: "figure.seated.seatbelt") }
            else if step == 2 { HStack(spacing: 40) { Image(systemName: "car.side.fill"); Image(systemName: "figure.walk") } }
            else if step == 3 { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) }
            else if step == 4 { HStack { Image(systemName: "car.front.waves.up.fill"); Image(systemName: "flag.fill").foregroundColor(.red) } }
            else { Image(systemName: "phone.fill.arrow.up.right") }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct TornadoProtocolIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "eyes"); Image(systemName: "tornado") } }
            else if step == 1 { HStack { Image(systemName: "arrow.down.to.line"); Image(systemName: "house.fill") } }
            else if step == 2 { HStack { Image(systemName: "bed.double.fill"); Image(systemName: "arrow.down") } }
            else if step == 3 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "arrow.right.circle.fill").foregroundColor(.red) } } // conceptually mobile home
            else if step == 4 { Image(systemName: "figure.roll") }
            else { HStack { Image(systemName: "bolt.slash.fill"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct FireEscapePlanIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "door.left.hand.open"); Text("2").font(.title).bold(); Image(systemName: "window.casement") } }
            else if step == 1 { Image(systemName: "sensor.fill") }
            else if step == 2 { HStack { Image(systemName: "figure.walk"); Image(systemName: "person.3.fill") } }
            else if step == 3 { HStack { Image(systemName: "smoke.fill"); Image(systemName: "arrow.down") } }
            else if step == 4 { HStack { Image(systemName: "hand.raised.fill"); Image(systemName: "door.left.hand.closed") } }
            else { Image(systemName: "tree.fill") }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct SignalForRescueIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Text("3").font(.system(size: 80, weight: .bold)); Image(systemName: "exclamationmark.3") } }
            else if step == 1 { Image(systemName: "speaker.wave.3.fill") }
            else if step == 2 { Image(systemName: "flashlight.on.fill") }
            else if step == 3 { Text("SOS").font(.system(size: 80, weight: .bold)) }
            else if step == 4 { Image(systemName: "sun.max.fill") }
            else { HStack { Image(systemName: "figure.stand"); Image(systemName: "mappin.and.ellipse") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EarthquakeProtocolIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "arrow.down.to.line"); Image(systemName: "figure.stand") } }
            else if step == 1 { HStack { Image(systemName: "menubar.dock.rectangle"); Image(systemName: "arrow.down") } } // table concept
            else if step == 2 { Image(systemName: "hand.raised.fill") }
            else if step == 3 { HStack { Image(systemName: "building.fill"); Image(systemName: "arrow.right.to.line") } }
            else if step == 4 { HStack { Image(systemName: "figure.run"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else { HStack { Image(systemName: "cross.case.fill"); Image(systemName: "building.2.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct PowerOutageKitIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "flashlight.on.fill"); Image(systemName: "battery.100") } }
            else if step == 1 { HStack { Image(systemName: "drop.fill"); Text("1 gal").font(.title).bold() } }
            else if step == 2 { Image(systemName: "radio.fill") }
            else if step == 3 { HStack { Image(systemName: "snowflake"); Image(systemName: "drop.fill") } }
            else if step == 4 { Image(systemName: "bolt.batteryblock.fill") }
            else { HStack { Image(systemName: "refrigerator.fill"); Image(systemName: "timer") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct FloodSurvivalIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "arrow.up.right"); Image(systemName: "mountain.2.fill") } }
            else if step == 1 { HStack { Image(systemName: "figure.walk"); Image(systemName: "water.waves"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else if step == 2 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "water.waves") } }
            else if step == 3 { HStack { Image(systemName: "building.fill"); Image(systemName: "arrow.up") } }
            else if step == 4 { Image(systemName: "phone.fill.arrow.up.right") }
            else { HStack { Image(systemName: "water.waves"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct GasLeakResponseIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "nose.fill") }
            else if step == 1 { HStack { Image(systemName: "lightswitch.on.square"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else if step == 2 { HStack { Image(systemName: "candybarphone"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else if step == 3 { HStack { Image(systemName: "window.casement"); Image(systemName: "arrow.left.and.right") } }
            else if step == 4 { HStack { Image(systemName: "figure.walk"); Image(systemName: "arrow.right.to.line") } }
            else { Image(systemName: "phone.fill.arrow.up.right") }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct SelfDefenseBasicsIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "figure.run") }
            else if step == 1 { HStack { Image(systemName: "speaker.wave.3.fill"); Text("FIRE").font(.title).bold() } }
            else if step == 2 { HStack { Image(systemName: "figure.stand"); Image(systemName: "hand.raised.fill") } }
            else if step == 3 { Image(systemName: "eye.fill") }
            else if step == 4 { Image(systemName: "hand.raised.fill") }
            else { HStack { Image(systemName: "arrow.turn.up.right"); Image(systemName: "hand.raised.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct NavigateWithoutGPSIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "sun.max.fill"); Image(systemName: "arrow.right") } }
            else if step == 1 { Image(systemName: "clock.fill") }
            else if step == 2 { HStack { Image(systemName: "star.fill"); Image(systemName: "arrow.up") } }
            else if step == 3 { Image(systemName: "tree.fill") }
            else if step == 4 { HStack { Image(systemName: "water.waves"); Image(systemName: "arrow.down") } }
            else { HStack { Image(systemName: "line.3.horizontal"); Image(systemName: "mappin.circle.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EmergencyRadioUseIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "radio.fill"); Text("NOAA").font(.title).bold() } }
            else if step == 1 { HStack { Image(systemName: "radio.fill"); Text("Ch 9").font(.title).bold() } }
            else if step == 2 { HStack { Image(systemName: "candybarphone"); Text("Ch 1").font(.title).bold() } }
            else if step == 3 { HStack { Image(systemName: "mic.fill"); Image(systemName: "person.wave.2.fill") } }
            else if step == 4 { Text("MAYDAY").font(.title).bold() }
            else { HStack { Image(systemName: "ear"); Image(systemName: "timer") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct LiftFreeFallIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "figure.walk"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } } // no jumping
            else if step == 1 { Image(systemName: "figure.roll") } // lie flat
            else if step == 2 { HStack { Image(systemName: "figure.stand"); Image(systemName: "hand.raised.fill") } } // cover head
            else if step == 3 { HStack { Image(systemName: "figure.stand"); Image(systemName: "rectangle.fill") } } // hold handrail
            else if step == 4 { Image(systemName: "arrow.down") }
            else { Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red) } // alarm button
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct StopDogAttackIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "figure.run"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else if step == 1 { HStack { Image(systemName: "eye.fill"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else if step == 2 { HStack { Image(systemName: "figure.stand"); Image(systemName: "shield.fill") } } // barrier
            else if step == 3 { Image(systemName: "figure.roll") }
            else if step == 4 { Image(systemName: "hand.raised.fill") }
            else { HStack { Image(systemName: "drop.fill"); Image(systemName: "cross.case.fill") } } // wash and med
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct LightningSafetyIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "bolt.fill"); Image(systemName: "timer") } }
            else if step == 1 { HStack { Image(systemName: "house.fill"); Image(systemName: "arrow.right.circle.fill") } }
            else if step == 2 { HStack { Image(systemName: "powerplug.fill"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else if step == 3 { Image(systemName: "figure.stand") } // crouch concept
            else if step == 4 { HStack { Image(systemName: "tree.fill"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else { Image(systemName: "phone.fill.arrow.up.right") }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct CarbonMonoxideSafetyIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "sensor.fill") }
            else if step == 1 { Image(systemName: "face.dotted") } // symptoms
            else if step == 2 { HStack { Image(systemName: "figure.walk"); Image(systemName: "arrow.right.to.line") } }
            else if step == 3 { Image(systemName: "phone.fill.arrow.up.right") }
            else if step == 4 { HStack { Image(systemName: "engine.combustion.fill"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
            else { HStack { Image(systemName: "flame.fill"); Image(systemName: "slash.circle.fill").foregroundColor(.red) } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct HurricanePreparednessIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "map.fill"); Image(systemName: "arrow.triangle.pull") } }
            else if step == 1 { Image(systemName: "briefcase.fill") } // Go Kit
            else if step == 2 { HStack { Image(systemName: "window.casement"); Image(systemName: "xmark") } } // board up
            else if step == 3 { HStack { Image(systemName: "bathtub.fill"); Image(systemName: "drop.fill") } }
            else if step == 4 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "arrow.right") } }
            else { HStack { Image(systemName: "house.fill"); Image(systemName: "shield.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct WildfireEvacuationIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "arrow.right") } }
            else if step == 1 { Image(systemName: "briefcase.fill") }
            else if step == 2 { HStack { Image(systemName: "tshirt.fill"); Image(systemName: "facemask.fill") } }
            else if step == 3 { HStack { Image(systemName: "car.side.fill"); Image(systemName: "wind") } }
            else if step == 4 { Image(systemName: "phone.fill.arrow.up.right") }
            else { HStack { Image(systemName: "house.fill"); Image(systemName: "shield.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct BuildShelterIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "tree.fill"); Image(systemName: "arrow.right.to.line"); Image(systemName: "house.fill") } }
            else if step == 1 { Image(systemName: "pencil.and.outline") } // ridge pole
            else if step == 2 { HStack(spacing: 2) { ForEach(0..<5) { _ in Image(systemName: "line.diagonal") } } }
            else if step == 3 { Image(systemName: "squareshape.split.3x3") }
            else if step == 4 { HStack { Image(systemName: "leaf.fill"); Image(systemName: "arrow.down") } }
            else { HStack { Image(systemName: "leaf.fill"); Image(systemName: "arrow.right.to.line") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct StartFireNoMatchIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "leaf.fill"); Image(systemName: "flame.fill") } }
            else if step == 1 { Image(systemName: "scissors") } // carve spindle
            else if step == 2 { Image(systemName: "waveform.path.badge.minus") } // bow string
            else if step == 3 { HStack { Image(systemName: "arrow.up.and.down"); Image(systemName: "flame.fill").opacity(0.5) } }
            else if step == 4 { HStack { Image(systemName: "flame.fill").foregroundColor(.red); Image(systemName: "arrow.right") } }
            else { HStack { Image(systemName: "wind"); Image(systemName: "flame.fill").foregroundColor(.orange) } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct PurifyWaterIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "drop.fill"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } }
            else if step == 1 { HStack { Image(systemName: "drop.fill"); Image(systemName: "flame.fill").foregroundColor(.red) } }
            else if step == 2 { HStack { Image(systemName: "tshirt.fill"); Image(systemName: "arrow.down") } }
            else if step == 3 { HStack { Image(systemName: "drop.fill"); Text("2\u{2080}").font(.title).bold() } } // bleach drops
            else if step == 4 { HStack { Image(systemName: "sun.max.fill"); Image(systemName: "timer") } }
            else { HStack { Image(systemName: "line.3.horizontal.decrease"); Image(systemName: "flame.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct IdentifyEdiblePlantsIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "leaf.fill"); Image(systemName: "questionmark.circle.fill") } }
            else if step == 1 { HStack { Image(systemName: "hand.point.up.left.fill"); Image(systemName: "timer") } }
            else if step == 2 { HStack { Image(systemName: "mouth.fill"); Image(systemName: "timer") } }
            else if step == 3 { HStack { Image(systemName: "mouth.fill"); Image(systemName: "exclamationmark.triangle.fill") } }
            else if step == 4 { HStack { Image(systemName: "leaf.fill"); Image(systemName: "checkmark.circle.fill").foregroundColor(.green) } }
            else { HStack { Image(systemName: "leaf.fill"); Image(systemName: "xmark.circle.fill").foregroundColor(.red) } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct NavigateByStarsIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "star.fill"); Image(systemName: "arrow.up"); Image(systemName: "star.fill") } }
            else if step == 1 { HStack { Image(systemName: "star.fill").foregroundColor(.yellow); Text("N").font(.title).bold() } }
            else if step == 2 { HStack { Image(systemName: "star.fill"); Text("S").font(.title).bold() } }
            else if step == 3 { HStack { Text("E").font(.title).bold(); Image(systemName: "arrow.right"); Text("W").font(.title).bold() } }
            else if step == 4 { HStack { Image(systemName: "eye.fill"); Image(systemName: "line.diagonal") } }
            else { HStack { Image(systemName: "star.fill"); Image(systemName: "arrow.left.and.right") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct SetSnareTrapIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) }
            else if step == 1 { HStack { Image(systemName: "pawprint.fill"); Image(systemName: "magnifyingglass") } }
            else if step == 2 { Image(systemName: "circle.dashed") }
            else if step == 3 { HStack { Image(systemName: "hand.raised.fill"); Image(systemName: "arrow.left.and.right") } }
            else if step == 4 { HStack { Image(systemName: "tree.fill"); Image(systemName: "circle.dashed") } }
            else { HStack { Image(systemName: "circle.dashed"); Image(systemName: "timer") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct CrossRiverIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "eye.fill"); Image(systemName: "water.waves") } }
            else if step == 1 { HStack { Image(systemName: "figure.walk"); Image(systemName: "arrow.down.to.line") } }
            else if step == 2 { HStack { Image(systemName: "shoe.fill"); Image(systemName: "checkmark.circle.fill").foregroundColor(.green) } }
            else if step == 3 { HStack { Image(systemName: "figure.walk"); Image(systemName: "line.diagonal") } }
            else if step == 4 { HStack { Image(systemName: "arrow.up.right"); Image(systemName: "water.waves") } }
            else { HStack { Image(systemName: "figure.pool.swim"); Image(systemName: "arrow.right") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct BearEncounterIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "figure.stand"); Image(systemName: "xmark.circle.fill").foregroundColor(.red) } } // dont run
            else if step == 1 { HStack { Image(systemName: "figure.arms.open"); Image(systemName: "speaker.wave.2.fill") } }
            else if step == 2 { HStack { Image(systemName: "arrow.backward"); Image(systemName: "eye.slash.fill") } }
            else if step == 3 { Image(systemName: "figure.roll") } // play dead
            else if step == 4 { HStack { Image(systemName: "hand.raised.fill"); Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red) } } // fight back
            else { HStack { Image(systemName: "spray.bottle.fill"); Image(systemName: "wind") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct SignalWithMirrorIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "sun.max.fill") }
            else if step == 1 { HStack { Image(systemName: "sun.max.fill"); Image(systemName: "hand.raised.fill") } }
            else if step == 2 { Image(systemName: "hand.point.up.left.fill") } // V shape concept
            else if step == 3 { HStack { Image(systemName: "sun.max.fill"); Image(systemName: "arrow.right") } }
            else if step == 4 { Text("SOS").font(.system(size: 80, weight: .bold)) }
            else { HStack { Image(systemName: "eye.fill"); Text("50m").font(.title).bold() } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct TieSurvivalKnotsIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "link.circle.fill"); Image(systemName: "crown.fill") } }
            else if step == 1 { Image(systemName: "circle.dashed") }
            else if step == 2 { HStack { Image(systemName: "tree.fill"); Image(systemName: "link") } }
            else if step == 3 { HStack { Image(systemName: "tent.fill"); Image(systemName: "link") } }
            else if step == 4 { Image(systemName: "number.square.fill") } // conceptual for figure 8
            else { HStack { Image(systemName: "link"); Image(systemName: "link") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EscapeRipCurrentIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "brain.head.profile"); Image(systemName: "hand.raised.fill") } }
            else if step == 1 { HStack { Image(systemName: "figure.pool.swim"); Image(systemName: "xmark.circle.fill").foregroundColor(.red) } }
            else if step == 2 { HStack { Image(systemName: "arrow.left.and.right"); Image(systemName: "water.waves") } }
            else if step == 3 { HStack { Image(systemName: "figure.pool.swim"); Image(systemName: "timer") } } // float / tread
            else if step == 4 { HStack { Image(systemName: "arrow.up.right"); Image(systemName: "house.fill") } } // back to shore
            else { HStack { Image(systemName: "person.wave.2.fill"); Image(systemName: "lifebuoy.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct AvalancheSurvivalIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "arrow.left.and.right"); Image(systemName: "cloud.snow.fill") } }
            else if step == 1 { HStack { Image(systemName: "tree.fill"); Image(systemName: "bag.fill").opacity(0.5) } }
            else if step == 2 { HStack { Image(systemName: "figure.pool.swim"); Image(systemName: "arrow.up") } } // swim up
            else if step == 3 { HStack { Image(systemName: "hand.raised.fill"); Image(systemName: "mouth.fill") } } // air pocket
            else if step == 4 { HStack { Image(systemName: "drop.fill"); Image(systemName: "arrow.up") } } // gravity
            else { HStack { Image(systemName: "ear"); Image(systemName: "speaker.wave.3.fill") } } // shout when hear
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}
struct MakeTorchIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "line.diagonal"); Image(systemName: "tshirt.fill") } }
            else if step == 1 { HStack { Image(systemName: "drop.fill").foregroundColor(.orange); Image(systemName: "arrow.down") } } // sap/fat
            else if step == 2 { Image(systemName: "link") } // secure
            else if step == 3 { HStack { Image(systemName: "flame.fill").foregroundColor(.orange); Image(systemName: "arrow.right.to.line") } }
            else if step == 4 { HStack { Image(systemName: "timer"); Text("30m").font(.title).bold() } }
            else { HStack { Image(systemName: "cylinder.fill"); Image(systemName: "flame.fill") } } // tin can
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct TarpShelterSetupIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "tree.fill"); Image(systemName: "tent.fill"); Image(systemName: "tree.fill") } }
            else if step == 1 { HStack { Image(systemName: "tent.2.fill") } } // lean to
            else if step == 2 { HStack { Image(systemName: "wind"); Image(systemName: "arrow.turn.down.right") } }
            else if step == 3 { HStack { Image(systemName: "rhombus.fill"); Image(systemName: "arrow.down.to.line") } } // rocks weight
            else if step == 4 { HStack { Image(systemName: "arrow.left.and.right"); Image(systemName: "tent.fill") } }
            else { HStack { Image(systemName: "leaf.fill"); Image(systemName: "arrow.down.to.line") } } // ground cover
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct DIYWaterFilterIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "waterbottle.fill"); Image(systemName: "scissors") } }
            else if step == 1 { Image(systemName: "tshirt.fill") }
            else if step == 2 { Image(systemName: "rhombus.fill").foregroundColor(.black) } // charcoal
            else if step == 3 { HStack(spacing: 0) { Image(systemName: "circle.fill").font(.system(size: 20)); Image(systemName: "circle.fill").font(.system(size: 40)) } } // sand/gravel
            else if step == 4 { HStack { Image(systemName: "drop.fill"); Image(systemName: "arrow.down"); Image(systemName: "cup.and.saucer.fill") } }
            else { HStack { Image(systemName: "flame.fill").foregroundColor(.red); Image(systemName: "drop.fill") } } // boil
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct ImprovisedCompassIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { Image(systemName: "pin.fill") }
            else if step == 1 { HStack { Image(systemName: "magnet"); Image(systemName: "arrow.right"); Text("50x").font(.title).bold() } }
            else if step == 2 { HStack { Image(systemName: "leaf.fill"); Image(systemName: "water.waves") } }
            else if step == 3 { HStack { Image(systemName: "pin.fill"); Image(systemName: "arrow.down"); Image(systemName: "leaf.fill") } }
            else if step == 4 { HStack { Image(systemName: "arrow.2.circlepath"); Image(systemName: "location.north.fill") } }
            else { HStack { Image(systemName: "sun.max.fill"); Text("E").font(.title).bold() } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct EmergencyWhistleIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "hands.sparkles.fill"); Image(systemName: "speaker.wave.3.fill") } }
            else if step == 1 { HStack { Image(systemName: "leaf.fill"); Image(systemName: "mouth.fill") } } // acorn concept
            else if step == 2 { Image(systemName: "hands.clap.fill") } // cupped hands
            else if step == 3 { HStack { Text("3x").font(.title).bold(); Image(systemName: "speaker.wave.3.fill") } }
            else if step == 4 { HStack { Image(systemName: "timer"); Text("1mi").font(.title).bold() } }
            else { HStack { Image(systemName: "bag.fill"); Image(systemName: "speaker.wave.3.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct CollectRainwaterIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "cloud.rain.fill"); Image(systemName: "cup.and.saucer.fill") } }
            else if step == 1 { HStack { Image(systemName: "tent.fill"); Image(systemName: "arrow.down.right"); Image(systemName: "drop.fill") } } // tarp angle
            else if step == 2 { HStack { Image(systemName: "circle.fill"); Image(systemName: "arrow.down.to.line") } } // stone
            else if step == 3 { HStack { Image(systemName: "sun.horizon.fill"); Image(systemName: "tshirt.fill") } } // dew
            else if step == 4 { HStack { Image(systemName: "tree.fill"); Image(systemName: "drop.triangle") } } // banana tree/tropical
            else { HStack { Image(systemName: "drop.fill"); Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange) } } // boil
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct BuildEmergencyKitIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "drop.fill"); Text("3d").font(.title).bold() } }
            else if step == 1 { HStack { Image(systemName: "takeoutbag.and.cup.and.straw.fill"); Text("3d").font(.title).bold() } }
            else if step == 2 { Image(systemName: "cross.case.fill") }
            else if step == 3 { HStack { Image(systemName: "flashlight.on.fill"); Image(systemName: "radio.fill") } }
            else if step == 4 { HStack { Image(systemName: "doc.text.fill"); Image(systemName: "dollarsign.circle.fill") } }
            else { HStack { Image(systemName: "battery.100"); Image(systemName: "facemask.fill") } }
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}

struct SurvivalHygieneIllustration: View {
    let step: Int; let color: Color
    var body: some View {
        ZStack {
            if step == 0 { HStack { Image(systemName: "hands.sparkles.fill"); Image(systemName: "drop.fill") } }
            else if step == 1 { HStack { Image(systemName: "mouth.fill"); Image(systemName: "line.diagonal") } } // twig brush
            else if step == 2 { HStack { Image(systemName: "arrow.down.to.line"); Text("6\"").font(.title).bold() } } // bury waste
            else if step == 3 { Image(systemName: "bandage.fill") }
            else if step == 4 { HStack { Image(systemName: "shoe.fill"); Image(systemName: "sun.max.fill") } } // dry feet
            else { HStack { Image(systemName: "flame.fill").foregroundColor(.red); Image(systemName: "fork.knife") } } // boil utensils
        }.font(.system(size: 60, weight: .light)).foregroundColor(color)
    }
}
