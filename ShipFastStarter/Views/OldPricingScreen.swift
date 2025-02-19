//
//  CustomPlanView.swift
//  Resolved
//
//  Created by Gursewak Singh on 25/09/24.
//

import SwiftUI
import RevenueCat
import SwiftData
import SuperwallKit
import StoreKit

struct OldPricingScreen: View {
    @State private var selectedPlan: String? = nil // Track selected plan
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    var userName: String = "Dante"
    var quitDate: String = "Dec 20, 2024"
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertDescription = ""
    @State private var animateContent = false
    @Query private var user: [User]
    @State private var animateSection1 = false
    @State private var animateSection2 = false
    @State private var animateSection3 = false
    @State private var presentReferral = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                // .scaleEffect(x: 1, y: -1, anchor: .center)
                .edgesIgnoringSafeArea(.all)
                .opacity(1)
            VStack(alignment: .center) {
                ZStack(alignment: .center) {
//                    Image(.nafsBackground)
//                        .resizable()
//                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.screenHeight)
//                        .scaledToFit()
//                        .scaleEffect(x: 1, y: -1, anchor: .center)
//                        .edgesIgnoringSafeArea(.all)
//                        .offset(y: -196)
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Spacer()
                            VStack(spacing: 8) {
                                // First section with name and date
                                VStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32)
                                        .foregroundColor(.white)
                                        .offset(y: -16)
                                    Text("\(mainVM.currUser.name), we've made\nyour custom plan.")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 20)
                                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)
                                    
                                    Text("You should quit porn by:")
                                        .sfFont(weight: .semibold, size: .h3p1)
                                        .foregroundColor(.white)
                                        .padding(.top, 32)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 20)
                                        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)
                                    
                                    Text(getFiftyDaysFromNow(), style: .date)
                                        .sfFont(weight: .semibold, size: .h3p1)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 20)
                                        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                                }
                                .padding(.bottom, 32)
                                
                                // Divider
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.white.opacity(0.2))
                                    .padding(.horizontal, 64)
                                    .padding(.vertical, 32)
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                            
                                
                                // Rest of your existing capsule buttons code...
                            }
                            .padding(.top, 32)
                            .offset(y: 48)
                            // Star rating and title
                            
                            VStack(spacing: 20) {
                                Image(.stars)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 248)
                                    .padding(.top)
                                
                                Text("Become the best of yourself with Seed")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text("Stronger. Healthier. Happier.")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }.padding(20)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)
                            
                            
                            
                            
                            // New Section: "Conquer Yourself" Section
                            VStack {
                                // insert stack of benefit capsules
                                VStack(spacing: 8) {
                                    HStack(spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "figure.strengthtraining.traditional")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("Increased Testosterone")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#00345A"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "cross.case")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("No Erectile Dysfunction")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#5E4500"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    .opacity(animateSection1 ? 1 : 0)
                                    .offset(y: animateSection1 ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.1), value: animateSection1)
                                    .onAppear { animateSection1 = true }
                                    
                                    HStack(spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "bolt.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("Increased Energy")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#5B5A00"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("Increased Motivation")
                                                .foregroundColor(.white)
                                                .font(.system(size: 9))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#005341"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "gearshape.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("Improved Focus")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#4F005A"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    .opacity(animateSection2 ? 1 : 0)
                                    .offset(y: animateSection2 ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.2), value: animateSection2)
                                    .onAppear { animateSection2 = true }
                                    
                                    HStack(spacing: 4) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("Improved Relationships")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#024F54"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.fill.checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                            Text("Increased Confidence")
                                                .foregroundColor(.white)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#62190F"))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    .opacity(animateSection3 ? 1 : 0)
                                    .offset(y: animateSection3 ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateSection3)
                                    .onAppear { animateSection3 = true }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 10) {
                                    LottieView(loopMode: .loop, animation: "meditatingMan", isVisible: .constant(true))
                                        .frame(width: 300, height: 300)
                                    
                                    Text("1. Conquer yourself")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.red)
                                            Text("Build unbreakable self-control")
                                                .fontWeight(.semibold).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(.purple)
                                            Text("Become more attractive and confident")
                                                .fontWeight(.semibold).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Boost your self-worth")
                                                .fontWeight(.semibold).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "smiley.fill")
                                                .foregroundColor(.yellow)
                                            Text("Fill each day with pride and happiness")
                                                .fontWeight(.semibold).foregroundColor(.white)
                                        }
                                    }
                                    .padding(.bottom, 30)
                                    
                                    // Star rating at the bottom
                                    VStack(spacing: 10) {
                                        // BenefitRow with complete border around
                                        HStack(spacing: 10) {
                                            ForEach(0..<5) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding(12)  // Padding around the entire HStack
                                        .background(Color.black.opacity(0.5))  // Background color
                                        .cornerRadius(20)  // Rounded corners
                                        .overlay(  // Add border to the entire view
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        
                                    }
                                    
                                    Text("'seed helped me overcome my 10 year battle with porn. i now finally have a steady long-term relationship, and haven't gone back since.'")
                                    //                            .defaultFont(size: 18)
                                        .sfFont(weight: .medium, size: .p2)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(24)
                                }
                                VStack(spacing: 10) {
                                    Text("Leonard Anderson (33M)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(.white.opacity(0.2))
                                        .padding(.horizontal, 64)
                                        .padding(.vertical, 32)
                                    // Add a representative image (replace with your actual image asset)
                                    LottieView(loopMode: .loop, animation: "friends", isVisible: .constant(true))
                                        .frame(width: 300, height: 300)
                                    
                                    Text("2. Build real relationships")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Enhance your emotional intelligence")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Be more trustworthy and dependable")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Experience real intimacy and connectoin")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Become the person they deserve")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                    }
                                    .padding(.bottom, 30)
                                    
                                    // Star rating at the bottom
                                    VStack(spacing: 10) {
                                        // BenefitRow with complete border around
                                        HStack(spacing: 10) {
                                            ForEach(0..<5) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding(12)  // Padding around the entire HStack
                                        .background(Color.black.opacity(0.5))  // Background color
                                        .cornerRadius(20)  // Rounded corners
                                        .overlay(  // Add border to the entire view
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        
                                    }
                                    
                                    Text("'porn is the silent killer of everything in ur life. don't fall into the trap believing it's not affecting u. once i embraced this, i was able to change.'")
                                        .sfFont(weight: .medium, size: .p2)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    
                                        .padding(24)
                                }
                                
                                VStack {
                                    Text("Donovan Brin (23M)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    VStack {
                                        VStack(alignment: .center, spacing: 20) {
                                            
                                            Image(systemName: "hand.raised")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.white)
                                                .padding(.top, 12)
                                            Text("Simple, Daily Habits")
                                                .font(.title)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            
                                            
                                            Text("Seed teaches 100% science-based habits that create life-long freedom from pornography possible.")
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 12)
                                                .foregroundColor(.white)
                                            
                                            Text("You should quit porn by:")
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                            
                                            
                                            Text(getFiftyDaysFromNow(), style: .date)
                                                .sfFont(weight: .semibold, size: .h3p1)
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 12)
                                                .background(Color.white)
                                                .clipShape(Capsule())
                                            
                                            
                                            
                                            
                                            VStack(alignment: .leading, spacing: 15) {
                                                Text("How to reach your goal:")
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.white)
                                                    .sfFont(weight: .semibold, size: .h3p1)
                                                    .padding(.top)
                                                //                                        .defaultFont(size: 18)
//                                                HStack {
//                                                    Text("🛡️ Use Seed's content blocking filter")
//                                                        .fontWeight(.semibold)
//                                                        .foregroundColor(.white)
//                                                    
//                                                }
                                                HStack {
                                                    Text("🚨")
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                    Text("Press the Panic Button when feeling tempted")
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                    
                                                }
                                                HStack {
                                                    Text("🏴‍☠️ Pledge daily to not relapse")
                                                        .fontWeight(.semibold)                            .foregroundColor(.white)
                                                    
                                                }
                                                HStack {
                                                    Text("📓")
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                    Text("Track progress towards betterment")
                                                        .fontWeight(.semibold)                            .foregroundColor(.white)
                                                    
                                                }
                                            }.padding(.bottom, 12)
                                        }.padding(20)
                                    }.background(.black.opacity(0.5)).cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                                    .padding(24)
                                    
                                }
                                
                                VStack(spacing: 10) {
                                    // Add a representative image (replace with your actual image asset)
                                    LottieView(loopMode: .loop, animation: "trophy", isVisible: .constant(true))
                                          .frame(width: 300, height: 300)
                                          .padding(.top, 32)

                                    Text("3. Restore your natural sex drive")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                    
                                    
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            Image(systemName: "brain.fill")
                                                .foregroundColor(.red)
                                            Text("Rewire your brain to prefer real sex")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "repeat.circle.fill")
                                                .foregroundColor(.purple)
                                            Text("Reverse porn-induced desensitization")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Enjoy healthy and satisfying intimacy")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                    }
                                    .padding(.bottom, 30)
                                    
                                    // Star rating at the bottom
                                    VStack(spacing: 10) {
                                        // BenefitRow with complete border around
                                        HStack(spacing: 10) {
                                            ForEach(0..<5) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding(12)  // Padding around the entire HStack
                                        .background(Color.black.opacity(0.5))  // Background color
                                        .cornerRadius(20)  // Rounded corners
                                        .overlay(  // Add border to the entire view
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        
                                    }
                                    Text("'Didn't have the motivation or drive to do anything, after finally quitting, I've gained a profound love for life.'")
                                        .sfFont(weight: .medium, size: .p2)

                                    //                            .defaultFont(size: 18)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    
                                        .padding(12)
                                }
                                VStack(spacing: 10) {
                                    Text("Mitchell C. (28M)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    //                            .defaultFont(size: 12)
                                        .padding(10)
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(.white.opacity(0.2))
                                        .padding(.horizontal, 64)
                                        .padding(.vertical, 32)
                                    // Add a representative image (replace with your actual image asset)
                                    LottieView(loopMode: .loop, animation: "guyRidingGraph", isVisible: .constant(true))
                                        .frame(width: 300, height: 300)
                                        .padding(.top, 32)
                                    
                                    Text("4. Take back control")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        HStack {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.red)
                                            Text("Learn to redirect harmful cravings")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(.purple)
                                            Text("Regain focus and motivation")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.green)
                                            Text("Find real joy and satisfaction in life")
                                                .fontWeight(.regular).foregroundColor(.white)
                                        }
                                        //                            HStack {
                                        //                                Image(systemName: "smiley.fill")
                                        //                                    .foregroundColor(.yellow)
                                        //                                Text("Become the person they deserve")
                                        //                                    .fontWeight(.regular).foregroundColor(.white)
                                        //                            }
                                    }
                                    .padding(.bottom, 30)
//
//                                    // Star rating at the bottom
                                    VStack(spacing: 10) {
                                        // BenefitRow with complete border around
                                        HStack(spacing: 10) {
                                            ForEach(0..<5) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding(12)  // Padding around the entire HStack
                                        .background(Color.black.opacity(0.5))  // Background color
                                        .cornerRadius(20)  // Rounded corners
                                        .overlay(  // Add border to the entire view
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        
                                    }
                                    
                                    Text("'I've tried to rely on my willpower for years but realized in 2024 I needed tools and gamification to help me finally quit.'")
                                    //                            .defaultFont(size: 18)
                                        .sfFont(weight: .medium, size: .p2)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding([.horizontal, .top], 24)
                                    Text("Daniel Lee (19M)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment:.center, spacing: 8) {
                                    VStack (spacing: 12) {
                                        Text("Special Discount!")
                                            .font(.system(size: 24, weight: .heavy))
                                            .foregroundColor(.white)
                                        Text("Get 80% off Seed Pro")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        VStack(alignment:.center, spacing: 8) {
                                            
                                            Text("Claim Now")
                                                .sfFont(weight: .semibold, size: .p2)
                                                .foregroundColor(.black)
                                                .padding()
                                                .background(
                                                    Capsule()
                                                        .fill(Color.white)
                                                )
                                                .onTapGesture {
                                                    Analytics.shared.log(event: "CustomPlan: Tapped claim now")
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    withAnimation {
                                                        Superwall.shared.register(event: "better_deal", handler: mainVM.handler)
                                                    }
                                                }.padding(8)
                                            //                                        Text("Lowest price ever")
                                            //                                            .font(.system(size: 14, weight: .medium))
                                            //                                            .foregroundColor(.white.opacity(0.8))
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 0)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "2563EB"),  // Blue gradient start
                                                    Color(hex: "7C3AED")   // Purple gradient end
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "2563EB"),  // Blue gradient start
                                                Color(hex: "7C3AED")   // Purple gradient end
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                                }
                                .padding(.vertical, 20)
                                Text("Referral Code")
                                    .underline()
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        Analytics.shared.log(event: "CustomPlan: Tapped Referral")
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            presentReferral = true
                                        }
                                    }
                                    .padding(.vertical)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width)
                    }
                    VStack {
                        Spacer()
                        SharedComponents.PrimaryButton(img: Image(systemName: "arrow.right"), title: "Start rewiring") {
                            Analytics.shared.log(event: "CustomPlan: Tapped Start Rewiring")
                            // Show the pricing modal
                            DataManager.shared.saveContext(context: modelContext)
                            UserDefaults.standard.setValue(true, forKey: "sawPricing")
                            let fiveMinutesFromNow = Calendar.current.date(byAdding: .minute, value: 3, to: Date())
                            NotificationManager.scheduleNotification(id: "halfOff", title: "🎁 retain your seed in 2025", body: "50% off for the next 24 hours. close out & reopen the app.", date: fiveMinutesFromNow ?? Date(), deepLink: "ong://halfOff")
                            if mainVM.currUser.isPro {
                                mainVM.currentPage = .home
                            } else {
                                Superwall.shared.register(event: "soft_paywall", params: ["screen":"onboarding"], handler: mainVM.handler) {

                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 32)
                    }
                    .frame(height: 100, alignment: .top)
                    .background(Color(hex: "#03041E"))
                    .offset(y: UIScreen.main.bounds.height / 2 - 64)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: animateContent)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertDescription), dismissButton: .cancel())
            }
            .padding()
            .padding(.bottom, 232)
        }
        .sheet(isPresented: $presentReferral) {
            ReferralScreen()
                .environmentObject(mainVM)
                .environmentObject(profileVM)
        }
        .onAppearAnalytics(event: "CustomPlan: Screenload")
        .onAppear {
            if let user = user.first {
                mainVM.currUser = user
            }
            animateContent = true
        }
    }
    
    func getFiftyDaysFromNow() -> Date {
        let calendar = Calendar.current
        let daysToAdd = 50
        let currentDate = Date()
        let fiftyDaysFromNow = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate)
        return fiftyDaysFromNow ?? currentDate
    }
    

//        Purchases.shared.getOfferings { offerings, error in
//            if let packages = offerings?.current?.availablePackages {
//                Purchases.shared.purchase(package: packages.first!) { transaction, purchaserInfo, error, userCancelled in
//
//                    if error != nil {
//                        // handle error
//                        alertTitle = "PURCHASE FAILED"
//                        alertDescription = "Error: \(error!.localizedDescription)"
//                        showAlert.toggle()
//                    }
//
//                    if purchaserInfo?.entitlements["pro"]?.isActive == true {
//                        // success
//                        print("✅ PURCHASE SUCCESSFUL")
//
//                        alertTitle = "✅ PURCHASE SUCCESSFUL"
//                        alertDescription = "You are now subscribed"
//                        showAlert.toggle()
//                    }
//                }
//            } else {
//                alertTitle = "PURCHASE FAILED"
//                alertDescription = error?.localizedDescription ?? "An Error occured"
//                showAlert.toggle()
//
//            }
//        }
            
            
           
        
//    }
    
}



struct OldPricingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OldPricingScreen()
    }
}





//
struct PricingView: View {
    var body: some View {
        
        
        VStack {
//            HStack {
//                PricingCard(title: "Monthly", price: "$12.99", DiscountTotal: "").frame(height: 100).onTapGesture {
//                    print("tapped")
//                }
//                PricingCard(title: "Yearly", price: "$39.99", DiscountTotal: "20").frame(height: 100)
//                PricingCard(title: "Half off yearly", price: "$19.99", DiscountTotal: "").frame(height: 100)
//            }
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let DiscountTotal: String
    let isSelected: Bool // Track if this card is selected

    var body: some View {
        ZStack {
            VStack {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.top, 5)
                
                Text(price)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(isSelected ? Color.white : Color.gray) // Set background based on selection
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )

            if !DiscountTotal.isEmpty {
                Text(" SAVE \(DiscountTotal)% ")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.black)
                    .cornerRadius(5)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .offset(y: -30)
            }
        }
    }
}
