//
//  EventHome.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 12/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct EventHome: View {
    @Binding var EventMatchedGeometryEffect: String
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var OpenedEventMatchedGeometry = ""
    @State var OpenedEventSelecteditem = EventModel(id: "")
    @State var CreateEventMatchedGeometry = ""
    @State var EventInvitationsMatchedGeometry = ""
    @State var emptyStringBinding = ""
    @State var emptyStringBinding2 = ""
    @State var emptyDateBinding = Date()
    @State var emptyDateBinding2 = Date()
    @State var PastEventsMatchedGeometryEffect: String = ""
    @State var isLoading = true
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
            ConfettiBackground(themeController: themeController)
            VStack {
                HStack (spacing: 16) {
                    TitleHeader(title: "Events") {
//                        EventMatchedGeometryEffect  = "house.fill"
                        currentTab.changeTab(tab: "house.fill")
                    }
                    Spacer()
                    Menu {
                        Button("Create Event", action: {
                            withAnimation() {
                                CreateEventMatchedGeometry = "0"
                            }
                        })
                        if eventModel.pastEventItems.isNotEmpty {
                            Button("Past Events") {
                                withAnimation() {
                                    PastEventsMatchedGeometryEffect = "0"
                                }
                            }
                        }
                    } label: {
                        ZStack {
                                           Text(".")
                                               .font(.largeTitle.weight(.bold))
                                               .offset(y: -7)
                                           Text(".")
                                               .font(.largeTitle.weight(.bold))
                                           Text(".")
                                               .font(.largeTitle.weight(.bold))
                                               .offset(y: 7)
                                       }
                                       .foregroundColor(Color.black)
                                       .frame(width: 50, height: 15)
                                       .offset(x: 5, y: -10)
//                        ZStack {
//                            Image(systemName: "plus")
//                                .foregroundColor(.black)
//                                .font(.title2.weight(.bold))
//                        }
//                        .frame(width: 40)
//                        .contentShape(Rectangle())
                }
                    .padding(.horizontal, 16)
                }
                HStack {
                if eventModel.invitedEvents.count > 0 {
                Button(action: {
                    withAnimation() {
                        EventInvitationsMatchedGeometry = "0"
                    }
                }) {
                HStack {
               RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.mainColorInverse)
                    .frame(width: screenWidth/2, height: 39)
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: (screenWidth/2) - 2, height: 37)
                                .foregroundColor(themeController.theme.accent)
                                .overlay(
                                    ZStack {
                                        Text(eventModel.invitedEvents.count > 1 ? "\(eventModel.invitedEvents.count) INVITATIONS" : "\(eventModel.invitedEvents.count) INVITATION")
                                            .foregroundColor(Color.mainColorInverse)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                )
                            
                        }
                    )
//                    .padding(.top, 5)
                }
                }
            }
                    Spacer()

                }
                .padding(.horizontal)
                .padding(.bottom, 14)
                Rectangle()
                    .frame(width: screenWidth, height: 5)
                    .foregroundColor(Color.mainColorInverse)
                    .padding(.bottom, 10)
            

                Spacer()
//                if eventModel.eventItem.isNotEmpty {
                ZStack {
                    BirthdayGirlImage(CreateEventMatchedGeometry: $CreateEventMatchedGeometry)
                        .offset(y: -80)
                        .opacity(eventModel.eventItem.isNotEmpty ? 0.2 : 1)
                        .disabled(eventModel.eventItem.isNotEmpty ? true : false)
                    ScrollView(showsIndicators: false) {
                        ForEach(eventModel.eventItem.sorted(by: {$1.time > $0.time}), id: \.id) { item in
                            ZStack {
                                IndividualEvent(event: item, isFromEventHome: true, themeController: themeController)
                                    .id(item.id)
                                    .onTapGesture {
                                        withAnimation {
                                            OpenedEventMatchedGeometry = "0"
                                            OpenedEventSelecteditem = item
                                        }
                                    }
                                    .disabled(item.isLoading ? true : false)
                                if item.isLoading {
                                    ProgressView()
                                }
                            }
                            Rectangle()
                                .frame(width: screenWidth, height: 5)
                                .foregroundColor(Color.mainColorInverse)
                        }
                    }
                    //                } else {

                }
//                }
                Spacer()
            }
            .padding(.top, iOS15 ? 0 : 60)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation() {
                        isLoading = false
                    }
                }
            }
            if CreateEventMatchedGeometry != "" {
                CreateEventTabView(friendsDictionary: friendsDictionary, event: eventModel, CreateEventMatchedGeometry: $CreateEventMatchedGeometry, name: $emptyStringBinding, eventDescription: $emptyStringBinding2, date: $emptyDateBinding, dateEnd: $emptyDateBinding2, themeController: themeController)
                   
            }
            if pushNotificationVM.eventMatchedGeometry != "" {
                OpenedEventTabView(OpenedEventMatchedGeometry: $pushNotificationVM.eventMatchedGeometry, eventModel: pushNotificationVM.eventModel, event: $pushNotificationVM.event, friendsDictionary: friendsDictionary, EventMatchedGeometryEffect: $EventMatchedGeometryEffect, isFromInvitations: true, themeController: themeController)
                    .id(pushNotificationVM.profileMatchedGeometry)
                    .zIndex(pushNotificationVM.zIndex(.newEvent))
            }
            if OpenedEventMatchedGeometry != "" {
                OpenedEventTabView(OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, eventModel: eventModel, event: $OpenedEventSelecteditem, friendsDictionary: friendsDictionary, EventMatchedGeometryEffect: $EventMatchedGeometryEffect, themeController: themeController)
            }
                if EventInvitationsMatchedGeometry != "" {
                    EventInvitationHomeTabView(EventInvitationsMatchedGeometry: $EventInvitationsMatchedGeometry, eventModel: eventModel, friendsDictionary: friendsDictionary, themeController: themeController)
                }
            if PastEventsMatchedGeometryEffect != "" {
                PastEventsTabView(PastEventsMatchedGeometryEffect: $PastEventsMatchedGeometryEffect, eventModel: eventModel, friendsDictionary: friendsDictionary, themeController: themeController)
            }
        }
        .padding(.top, iOS15 ? 0 : -60)
    }
}

struct DummyEvent: View {
    @ObservedObject var eventModel: EventModelOO
    @Binding var event: EventModel
    init(eventModel: EventModelOO, event: Binding<EventModel>) {
        self.eventModel = eventModel
        self._event = event
    }
    var body: some View {
        EmptyView()
    }
}
struct PastEventsHome: View {
    @Binding var PastEventsMatchedGeometryEffect: String
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var OpenedEventMatchedGeometry = ""
    @State var OpenedEventSelecteditem = EventModel(id: "")
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
            ConfettiBackground(themeController: themeController)
            VStack {
                HStack (spacing: 16) {
                    TitleHeader(title: "Past Events") {
                        PastEventsMatchedGeometryEffect = ""
                        
                    }
                    Spacer()
                        EmptyView()
                        .frame(width: 50, height: 15)
                        .hidden()
                }
                Rectangle()
                    .frame(width: screenWidth, height: 5)
                    .foregroundColor(Color.mainColorInverse)
                    .padding(.bottom, 10)
                ScrollView(showsIndicators: false) {
                    ForEach(eventModel.pastEventItems.sorted(by: {$0.time > $1.time}), id: \.self) { item in
                        IndividualEvent(event: item, isFromEventHome: true, themeController: themeController)
                            .onTapGesture {
                                withAnimation {
                                    OpenedEventMatchedGeometry = "0"
                                    OpenedEventSelecteditem = item
                                }
                            }
                        Rectangle()
                            .frame(width: screenWidth, height: 5)
                            .foregroundColor(Color.mainColorInverse)
                            .padding(.bottom, 10)
                        
                    }
                }
                Spacer()
            }
            .padding(.top, iOS15 ? 0 : 16)
            .edgesIgnoringSafeArea(.bottom)
            if OpenedEventMatchedGeometry != "" {
                OpenedEventTabView(OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, eventModel: eventModel, event: $OpenedEventSelecteditem, friendsDictionary: friendsDictionary, EventMatchedGeometryEffect: .constant(""), themeController: themeController)
            }
        }
    }
}

struct PastEventsTabView: View {
    @Binding var PastEventsMatchedGeometryEffect: String
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    @State var selectedTab = "strangerProfile"
    var body: some View {
        if selectedTab == "strangerProfile" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    PastEventsHome(PastEventsMatchedGeometryEffect: $PastEventsMatchedGeometryEffect, eventModel: eventModel, friendsDictionary: friendsDictionary, themeController: themeController)
                        .tag("strangerProfile")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    PastEventsMatchedGeometryEffect = ""
                }
            
        }
    }
}

struct EventInvitationHome: View {
    @Binding var EventInvitationsMatchedGeometry: String
    @ObservedObject var eventModel: EventModelOO
    @State var OpenedEventMatchedGeometry = ""
    @State var OpenedEventSelecteditem = EventModel(id: "")
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
            ConfettiBackground(themeController: themeController)
            VStack {
                HStack (spacing: 16) {
                    TitleHeader(title: "Invitations") {
                        EventInvitationsMatchedGeometry  = ""
                    }
                    Spacer()
                    EmptyView()
                    .frame(width: 50, height: 15)
                    .hidden()
                }
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 39)
                    .padding(.bottom, 14)
                    .hidden()
                Rectangle()
                    .frame(width: screenWidth, height: 5)
                    .foregroundColor(Color.mainColorInverse)
                    .padding(.bottom, 10)
                ScrollView(showsIndicators: false) {
                    ForEach(eventModel.invitedEvents.sorted(by: {$1.time > $0.time}), id: \.self) { item in
                        IndividualEvent(event: item, isFromEventHome: true, themeController: themeController)
                            .onTapGesture {
                                withAnimation {
                                    OpenedEventMatchedGeometry = "0"
                                    OpenedEventSelecteditem = item
                                }
                            }
                        Rectangle()
                            .frame(width: screenWidth, height: 5)
                            .foregroundColor(Color.mainColorInverse)
                    }
                }
                Spacer()
            }
            .padding(.top, iOS15 ? 0 : 16)
            .edgesIgnoringSafeArea(.bottom)
            if OpenedEventMatchedGeometry != "" {
                OpenedEventTabView(OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, eventModel: eventModel, event: $OpenedEventSelecteditem, friendsDictionary: friendsDictionary, EventMatchedGeometryEffect: .constant(""), themeController: themeController)
            }
        }
//        .padding(.top, iOS15 ? 0 : -60)
    }
}
struct EventInvitationHomeTabView: View {
    @Binding var EventInvitationsMatchedGeometry: String
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    @State var selectedTab = "NewConversation"
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    EventInvitationHome(EventInvitationsMatchedGeometry: $EventInvitationsMatchedGeometry, eventModel: eventModel, friendsDictionary: friendsDictionary, themeController: themeController)
                        .tag("NewConversation")
                    //                        .padding(.top, 60)
                }
                .edgesIgnoringSafeArea(.bottom)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    EventInvitationsMatchedGeometry = ""
                }
        }
        
    }
}


struct IndividualEvent: View {
    @State var event: EventModel
    @State var isFromEventHome = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        
        ZStack {
                Color.mainColorInverse.opacity(0.001)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            VStack(alignment: .leading) {
                HStack (alignment: .top) {
                    IndividualDate(month: event.month, day: event.dateNumber, themeController: themeController)
                    
                    EventInformation(name: event.eventName, time: event.startTime)
                    
                    
                    Spacer()
                }
                
            }
            .padding(.bottom, isFromEventHome ? 100 : 0)
        }
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        
    }
}


struct IndividualDate: View {
    @State var month: String
    @State var day: String
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.accent
            ZStack {
                themeController.theme.primary
                VStack (spacing: 0) {
                    Text(month)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    Rectangle()
                        .frame(width: 60, height: 2)
                        .foregroundColor(.black)
                    
                    Text(day)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.black)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(width: 80, height: 80, alignment: .leading)
            
        } .clipShape(RoundedRectangle(cornerRadius: 25))
            .frame(width: 100, height: 100, alignment: .leading)
        
        
    }
}

struct EventInformation: View {
    @State var name: String
    @State var time: String
    var body: some View {
        VStack (alignment: .leading) {
            Text(name)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
            
            Text(time)
        }.foregroundColor(Color.black)
        
    }
}

struct BirthdayGirlImage: View {
    @Binding var CreateEventMatchedGeometry: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            withAnimation {
                CreateEventMatchedGeometry = "0"
            }
        }) {
//            Image(colorScheme == .light ? "birthdayGirl" : "birthdayGirlDark")
            Image("birthdayGirl3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenWidth/1.055, height: screenHeight/3.66)
                .opacity(1)
        }
    }
}

struct ConfettiBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            
//            Image(colorScheme == .light ? "confettiLight1" : "confettiDark")
//                .resizable()
//                .scaledToFill()
//                .opacity(0.1)
//                .overlay (
//                    themeController.theme.primary.opacity(1)
//                )
//                .frame(width: screenWidth, height: screenHeight - 150)
        }
//        .frame(width: screenWidth, height: screenHeight - 150)

    }
}
