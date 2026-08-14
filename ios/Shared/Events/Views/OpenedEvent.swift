//
//  OpenedEvent.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 8/4/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct OpenedEvent: View {
    @ObservedObject var eventModel: EventModelOO
    @StateObject var individualEvent = IndividualEventOO(eventID: "", friendsDictionary: FriendsDictionary())
    @State var event: EventModel
    @State var isHostShowing = true
    @State var isDescriptionShowing = true
    @State var isAttendingShowing = true
    @State var isInvitedShowing = false
    @State var isNotAttendingShowing = false
    @State var isLocationShowing = true
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var InviteMatchedGeometry: String = ""
    @State var isAHost = false
    @StateObject var functions = EventFunctions()
    @State var isCalendarShowing = true
    @State var isEditEventShowing = false
    @State var EditEventMatchedGeometry = ""
    @Binding var OpenedEventMatchedGeometry: String
    @StateObject var shareActivity = ShareActivityOO()
    @State var isRequestingToJoin = false
    @Binding var EventMatchedGeometryEffect: String
    @State var JoinRequestMatchedGeometry = ""
    @StateObject var requests = IndividualEventRequestedUsersOO(eventID: "", friendsDictionary: FriendsDictionary())
    @State var FriendProfileMatchedGeometry = ""
    @State var StrangerProfileSelectedUser = Person(id: "")
    @State var isFromInvitations = false
    @Environment(\.colorScheme) var colorScheme
    @State var isShowingMoreAttending = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack (alignment: .trailing) {
            ZStack {
                themeController.theme.messageList
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    
                    OpenedEventHeader(eventModel: eventModel, functions: functions, individualEvent: individualEvent, friendsDictionary: friendsDictionary, event: event, EditEventMatchedGeometry: $EditEventMatchedGeometry, NavigationMatchedGeomtry: $OpenedEventMatchedGeometry, themeController: themeController)
                    
                    ZStack {
                        if individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil {
                            EventJoinRequests(JoinRequestMatchedGeometry: $JoinRequestMatchedGeometry, requests: requests, themeController: themeController)
                        }
                    }
                    .padding(.top, iOS15 ? 0 : 50)
                    ScrollView() {
                    VStack (alignment: .leading, spacing: 10) {
                        if individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) == nil {
                            Rectangle()
                                .foregroundColor(Color.mainColorInverse)
                                .frame(width: screenWidth, height: 5)
                                .padding(.leading, -16)
                                .offset(y: -2)
                        }
                        HStack {
//                            Button(action: {
//                                withAnimation {
//                                    isHostShowing.toggle()
//                                }
//                            }) {
                                HStack {
                                    Text("HOST(s)")
                                        .font(.footnote)
                                        .fontWeight(.bold)
//                                    Text("^")
//                                        .font(.headline)
//                                        .rotationEffect(Angle(degrees: 180))
//                                        .padding(.bottom, 5)
                                }
//                            }
                            .foregroundColor(Color.black)
                            
                            Spacer()
                            if individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil {
                                HStack(spacing: 12) {

                                    Menu {
                                        Button("Add Event Hosts") {
                                            InviteMatchedGeometry = "0"
                                            isAHost = true
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(themeController.theme.accent)
                                            .font(.title3)
                                    }
                                }
                                .padding(.trailing)
                            }
                        }
                        .padding(.top, 5)
                        
                        if isHostShowing {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(individualEvent.hosts, id: \.self) { item in
                                        Button(action: {
                                            FriendProfileMatchedGeometry = item.id
                                            StrangerProfileSelectedUser = item
                                        }) {
                                            HStack {
                                                WebImage(url: item.webLink)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 35, height: 35)
                                                    .clipShape(Circle())
                                                Text(item.name)
                                                    .foregroundColor(Color.black)
                                            }
                                        }
                                        .padding(5)
                                        .padding(.trailing, 5)
                                        .background(Color.mainColor.opacity(0.03))
                                        .cornerRadius(10)
                                        .padding(.trailing, 5)
                                        .contentShape(Rectangle())
                                        
                                    }
                                }
                            }
                            
                        }
                        ZStack {
                            VStack(alignment: .leading) {
                                if event.eventDescription != "" {
                                    Divider()
//                                    Button(action: {
//                                        withAnimation {
//                                            isDescriptionShowing.toggle()
//                                        }
//                                    }) {
                                        HStack {
                                            Text("DESCRIPTION")
                                                .font(.footnote)
                                                .fontWeight(.bold)
//                                            Text("^")
//                                                .font(.headline)
//                                                .rotationEffect(Angle(degrees: 180))
//                                                .padding(.bottom, 5)
//                                        }
                                    }
                                        .padding(.vertical, 5)
                                        .foregroundColor(Color.black)
                                    if isDescriptionShowing {
                                        Text(event.eventDescription)
                                            .foregroundColor(Color.black)
                                    }
                                }
                                Divider()
//                                Button(action: {
//                                    withAnimation {
//                                        isLocationShowing.toggle()
//                                    }
//                                }) {
                                    HStack {
                                        Text("LOCATION")
                                            .font(.footnote)
                                            .fontWeight(.bold)
//                                        Text("^")
//                                            .font(.headline)
//                                            .rotationEffect(Angle(degrees: 180))
//                                            .padding(.bottom, 5)
                                    }
                                    .padding(.vertical, 5)
//                                }
                                .foregroundColor(Color.black)
                                if isLocationShowing {
                                    Text(event.location != "" ? event.location : "TBD")
                                        .foregroundColor(Color.black)
                                    
                                }
                                Divider()
                                LazyVStack (alignment: .leading) {
                                    VStack {
                                        if individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil || individualEvent.attendingFriends.isNotEmpty || individualEvent.attendingStrangers.isNotEmpty {
                                            HStack {
                                                Button(action: {
                                                    withAnimation {
                                                        if individualEvent.attendingFriends.isNotEmpty || individualEvent.attendingStrangers.isNotEmpty {
                                                            isAttendingShowing.toggle()
                                                        }
                                                    }
                                                }) {
                                                    HStack {
                                                        Text("ATTENDING (\(individualEvent.attendingFriends.count + individualEvent.attendingStrangers.count))")
                                                            .font(.footnote)
                                                            .fontWeight(.bold)
                                                        if individualEvent.attendingFriends.isNotEmpty || individualEvent.attendingStrangers.isNotEmpty {
                                                            Text("^")
                                                                .font(.headline)
                                                                .rotationEffect(Angle(degrees: isAttendingShowing ? 0 : 180))
                                                                .offset(y: isAttendingShowing ? 3 : -3)
                                                        }
                                                    }
                                                }
                                                .foregroundColor(Color.black)
                                                
                                                Spacer()
                                                if individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil {
                                                    HStack(spacing: 12) {
                                                        Menu {
                                                            Button("Share Event") {
                                                                shareActivity.getDynamicLink(isAnEvent: true, eventID: event.id)
                                                            }
                                                        } label: {
                                                            Image(systemName: "square.and.arrow.up")
                                                                .foregroundColor(themeController.theme.accent)
                                                                .font(.headline)
                                                            
                                                        }
                                                        .offset(y: -1)
                                                        Menu {
                                                            Button("Invite To Event") {
                                                                InviteMatchedGeometry = "0"
                                                            }
                                                        } label: {
                                                            Image(systemName: "plus.circle")
                                                                .foregroundColor(themeController.theme.accent)
                                                                .font(.title3)
                                                        }
                                                    }
                                                    
                                                    .padding(.trailing)
                                                }
                                            }
                                            .padding(.top, 5)
                                            
                                            
                                            if isAttendingShowing {
                                                //                                Group {
                                                ScrollView (showsIndicators: false){
                                                    LazyVStack {
                                                        ForEach (isShowingMoreAttending ? Array(individualEvent.attendingFriends) :  Array(individualEvent.attendingFriends.prefix(3)), id: \.self) { item in
                                                            //                                Text(item)
                                                            HStack {
                                                                WebImage(url: item.webLink)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 35, height: 35)
                                                                    .clipShape(Circle())
                                                                Text(item.name)
                                                                Spacer()
                                                            }
                                                            .foregroundColor(Color.black)
                                                            .contentShape(Rectangle())
                                                            .onTapGesture {
                                                                FriendProfileMatchedGeometry = item.id
                                                            }
                                                            .contextMenu {
                                                                if  (individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil)  && (individualEvent.hosts.firstIndex(where: {$0.id == item.id}) == nil) {
                                                                    VStack {
                                                                        Button(action: {
                                                                            individualEvent.removeAttending(id: item.id, person: item)
                                                                            functions.removeFromEvent(eventID: event.id, userID: item.id)
                                                                        }) {
                                                                            Text("Remove from Event")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            Divider()
                                                        }
                                                        ForEach (isShowingMoreAttending ?  Array(individualEvent.attendingStrangers) : individualEvent.attendingFriends.count < 3 ? Array(individualEvent.attendingStrangers.prefix(3-individualEvent.attendingFriends.count)) : Array(individualEvent.attendingStrangers.prefix(0)), id: \.self) { item in
                                                            HStack {
                                                                WebImage(url: item.webLink)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 35, height: 35)
                                                                    .clipShape(Circle())
                                                                Text(item.name)
                                                                Spacer()
                                                            }
                                                            .foregroundColor(Color.black)
                                                            .contentShape(Rectangle())
                                                            .onTapGesture {
                                                                FriendProfileMatchedGeometry = item.id
                                                                StrangerProfileSelectedUser = item
                                                            }
                                                            .contextMenu {
                                                                if  (individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil)  && (individualEvent.hosts.firstIndex(where: {$0.id == item.id}) == nil) {
                                                                    VStack {
                                                                        Button(action: {
                                                                            individualEvent.removeAttending(id: item.id, person: item)
                                                                            functions.removeFromEvent(eventID: event.id, userID: item.id)
                                                                        }) {
                                                                            Text("Remove from Event")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            Divider()
                                                        }
                                                    }
                                                }
                       
                                                //                                        .frame(height: (individualEvent.attendingFriends.count + individualEvent.attendingStrangers.count) > 7 ? 300 : CGFloat(((individualEvent.attendingFriends.count + individualEvent.attendingStrangers.count)) * 50) + 15)
                                                .edgesIgnoringSafeArea(.bottom)
                                            }
                                            if (individualEvent.attendingFriends.count + individualEvent.attendingStrangers.count > 3) {
                                                Button(action: {
                                                    withAnimation {
                                                        isShowingMoreAttending.toggle()
                                                    }
                                                }){
                                                    HStack {
                                                        Text(isShowingMoreAttending ? "SHOW LESS" : "SHOW MORE")
                                                        Text("^")
                                                            .rotationEffect(Angle(degrees: isShowingMoreAttending ? 0 : 180))
                                                            .offset(y: -3)
                                                    }
                                                    .font(.caption2)
                                                    .foregroundColor(Color.black.opacity(0.4))
                                                    .padding(.top, 5)
                                                    .padding(.bottom, 20)
                                                }
                                            }
                                        }
                                        if isAttendingShowing != true || (individualEvent.attendingFriends.isEmpty && individualEvent.attendingStrangers.isEmpty && individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil)  {
                                            Divider()
                                                .offset(y: -6)
                                        }
                                }
                             
                                    if individualEvent.invitedFriends.count != 0 || individualEvent.invitedStrangers.count != 0 {
                                        HStack {
                                            Button(action: {
                                                withAnimation {
                                                    isInvitedShowing.toggle()
                                                }
                                            }) {
                                                
                                                HStack {
                                                    Text("INVITED (\(individualEvent.invitedFriends.count + individualEvent.invitedStrangers.count))")
                                                        .font(.footnote)
                                                        .fontWeight(.bold)
                                                    Text("^")
                                                        .font(.headline)
                                                        .rotationEffect(Angle(degrees: isInvitedShowing ? 0 : 180))
                                                        .offset(y: isInvitedShowing ? 3 : -3)
                                                }
                                                
                                            }
                                            .foregroundColor(Color.black)
                                            
                                        }
//                                        .padding(.top, isInvitedShowing ? 20 : 0)
                                        if isInvitedShowing {
                                            ScrollView(showsIndicators: false) {
                                                ForEach (Array(individualEvent.invitedFriends), id: \.self) { item in
                                                    //                                Text(item)
                                                    HStack {
                                                        WebImage(url: item.webLink)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 35, height: 35)
                                                            .clipShape(Circle())
                                                        Text(item.name)
                                                        Spacer()
                                                    }
                                                    .foregroundColor(Color.black)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        FriendProfileMatchedGeometry = item.id
                                                    }
                                                    
                                                    .contextMenu {
                                                        if (individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil) && (individualEvent.hosts.firstIndex(where: {$0.id == item.id}) == nil) {
                                                            VStack {
                                                                Button(action: {
                                                                    individualEvent.removeInvited(id: item.id, person: item)
                                                                    functions.cancelEventInvitation(eventID: event.id, userID: item.id)
                                                                }) {
                                                                    Text("Cancel Invitation")
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Divider()
                                                }
                                                ForEach (Array(individualEvent.invitedStrangers), id: \.self) { item in
                                                    //                                Text(item)
                                                    HStack {
                                                        WebImage(url: item.webLink)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 35, height: 35)
                                                            .clipShape(Circle())
                                                        Text(item.name)
                                                        Spacer()
                                                    }
                                                    .foregroundColor(Color.black)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        FriendProfileMatchedGeometry = item.id
                                                        StrangerProfileSelectedUser = item
                                                    }
                                                    .contextMenu {
                                                        if (individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil) && (individualEvent.hosts.firstIndex(where: {$0.id == item.id}) == nil) {
                                                            VStack {
                                                                Button(action: {
                                                                    individualEvent.removeInvited(id: item.id, person: item)
                                                                    functions.cancelEventInvitation(eventID: event.id, userID: item.id)
                                                                }) {
                                                                    Text("Cancel Invitation")
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Divider()
                                                }
                                            }
                                            
                                        }
                                    }
                                    if isInvitedShowing != true && individualEvent.invitedFriends.count != 0 || individualEvent.invitedStrangers.count != 0  {
                                        Divider()
                                    }
                                    if individualEvent.notAttendingFriends.count != 0 || individualEvent.notAttendingStrangers.count != 0 {
                                        HStack {
                                            Button(action: {
                                                withAnimation {
                                                    isNotAttendingShowing.toggle()
                                                }
                                            }) {
                                                
                                                HStack {
                                                    Text("NOT ATTENDING (\(individualEvent.notAttendingFriends.count + individualEvent.notAttendingStrangers.count))")
                                                        .font(.footnote)
                                                        .fontWeight(.bold)
                                                    Text("^")
                                                        .font(.headline)
                                                        .rotationEffect(Angle(degrees: isNotAttendingShowing ? 0 : 180))
                                                        .offset(y: isNotAttendingShowing ? 3 : -3)
                                                }
                                                
                                            }
                                            .foregroundColor(Color.black)
                                            
                                        }
//                                        .padding(.top, isNotAttendingShowing ? 20 : 0)
                                        if isNotAttendingShowing {
                                            ScrollView(showsIndicators: false) {
                                                ForEach (Array(individualEvent.notAttendingFriends), id: \.self) { item in
                                                    //                                Text(item)
                                                    HStack {
                                                        WebImage(url: item.webLink)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 35, height: 35)
                                                            .clipShape(Circle())
                                                        Text(item.name)
                                                        Spacer()
                                                    }
                                                    .foregroundColor(Color.black)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        FriendProfileMatchedGeometry = item.id
                                                    }
                                                    .contextMenu {
                                                        if (individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil)  && (individualEvent.hosts.firstIndex(where: {$0.id == item.id}) == nil) {
                                                            VStack {
                                                                Button(action: {
                                                                    individualEvent.removeNotAttending(id: item.id, person: item)
                                                                    functions.removeFromEvent(eventID: event.id, userID: item.id)
                                                                }) {
                                                                    Text("Remove from Event")
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Divider()
                                                }
                                                ForEach (Array(individualEvent.notAttendingStrangers), id: \.self) { item in
                                                    //                                Text(item)
                                                    HStack {
                                                        WebImage(url: item.webLink)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 35, height: 35)
                                                            .clipShape(Circle())
                                                        Text(item.name)
                                                        Spacer()
                                                    }
                                                    .foregroundColor(Color.black)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        FriendProfileMatchedGeometry = item.id
                                                        StrangerProfileSelectedUser = item
                                                    }
                                                    .contextMenu {
                                                        if  (individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil)  && (individualEvent.hosts.firstIndex(where: {$0.id == item.id}) == nil) {
                                                            VStack {
                                                                Button(action: {
                                                                    individualEvent.removeNotAttending(id: item.id, person: item)
                                                                    functions.removeFromEvent(eventID: event.id, userID: item.id)
                                                                }) {
                                                                    Text("Remove from Event")
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Divider()
                                                }
                                            }
                                        }
                                    }
                                    if isNotAttendingShowing != true && individualEvent.notAttendingFriends.count != 0 || individualEvent.notAttendingStrangers.count != 0  {
                                        Divider()
                                    }
                                }
                            }
                            .blur(radius: isRequestingToJoin ? 10 : 0)
                            .disabled(isRequestingToJoin ? true : false)
                            if isRequestingToJoin {
                                RequestToAttendEventButtons(isRequestingToJoin: $isRequestingToJoin, functions: functions, friendsDictionary: friendsDictionary, event: event, OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, EventMatchedGeometryEffect: $EventMatchedGeometryEffect, themeController: themeController)
                                    .padding(.bottom, iOS15 ? 0 : screenHeight / 2.2)
                            }
                        }
                        
                    }
                    .padding(.leading)
                    .padding(.top, iOS16 ? 16 : 0)
                
                    Spacer()
                }
                .padding(.top, iOS15 ? 0 : 16)
            }
                .edgesIgnoringSafeArea(.bottom)
                if InviteMatchedGeometry != "" {
                    InviteToExistingEvent(eventModel: eventModel, friendsDictionary: friendsDictionary, individualEvent: individualEvent, event: event, InviteMatchedGeometry: $InviteMatchedGeometry, isAHost: $isAHost, themeController: themeController)
                }
                if isCalendarShowing != true {
                    EventConversationController(eventModel: eventModel, functions: functions, individualEvent: individualEvent, event: event, friendsDictionary: friendsDictionary, OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, EditEventMatchedGeometry: $EditEventMatchedGeometry, themeController: themeController)
  
                }
                if EditEventMatchedGeometry != "" {
                    EditEvent(friendsDictionary: friendsDictionary, eventModel: eventModel, functions: functions, month: event.month, day: event.dateNumber, name: event.eventName, time: event.startTime, description: event.eventDescription, location: event.location, existingDate: event.time.dateValue(), newDate: event.time.dateValue(), eventID: event.id, eventTime: event.time, EditEventMatchedGeometry: $EditEventMatchedGeometry, allAttendingTokens: individualEvent.allAttendingTokens, OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, themeController: themeController)
                    
                }
                if JoinRequestMatchedGeometry != "" {
                    EventJoinRequestsHomeTabView(JoinRequestMatchedGeometry: $JoinRequestMatchedGeometry, requests: requests, eventModel: eventModel, event: event, friendsDictionary: friendsDictionary, functions: functions, individualEvent: individualEvent, themeController: themeController)
                }
                if let _ = shareActivity.shareURL {
                    ActivityViewController(shareURL: $shareActivity.shareURL, isAnEvent: true)
                }
                if FriendProfileMatchedGeometry != "" {
                    if friendsDictionary.friendsDictionary[FriendProfileMatchedGeometry] != nil {
                        if FriendProfileMatchedGeometry != currentUserID {
                            FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: false, themeController: themeController)
                        } else {
                            CurrentUserProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: currentUserID ?? "",  signOut: .constant(false), friendsDictionary: friendsDictionary)
                        }
                    } else {
                        StrangerProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, person: StrangerProfileSelectedUser , id: FriendProfileMatchedGeometry)
                    }
                }
            }
//            if EditEventMatchedGeometry.isEmpty && FriendProfileMatchedGeometry == "" && JoinRequestMatchedGeometry == "" && isRequestingToJoin != true {
//            OpenedEventTabMenu2(isCalendarShowing: $isCalendarShowing)
//                    .offset(y: event.eventDescription != "" ? -100 : 100)
////                    .padding(.bottom, iOS15 ? 0 : 80)
//            }
        }
    }
}

struct OpenedEventTabView: View {
    @Binding var OpenedEventMatchedGeometry: String
    @ObservedObject var eventModel: EventModelOO
    @Binding var event: EventModel
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var selectedTab = "NewConversation"
    @State var isRequestingToJoin = false
    @Binding var EventMatchedGeometryEffect: String
    @State var isFromInvitations = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    OpenedEvent(eventModel: eventModel, individualEvent: IndividualEventOO(eventID: event.id, friendsDictionary: friendsDictionary), event: event, friendsDictionary: friendsDictionary, OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, isRequestingToJoin: isRequestingToJoin, EventMatchedGeometryEffect: $EventMatchedGeometryEffect, requests: IndividualEventRequestedUsersOO(eventID: event.id, friendsDictionary: friendsDictionary), isFromInvitations: isFromInvitations, themeController: themeController)
                        .tag("NewConversation")
                }
                .edgesIgnoringSafeArea(.bottom)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedEventMatchedGeometry = ""
                    event = EventModel(id: "")
                }
        }
        
    }
}


struct InviteToExistingEvent: View {
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var individualEvent: IndividualEventOO
    @State var event: EventModel
    @State var selectedUser = [String]()
    @State var falseBinding = false
    @State var trueBinding = true
    @Binding var InviteMatchedGeometry: String
    @Binding var isAHost: Bool
    @StateObject var functions = EventFunctions()
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    themeController.theme.primary
                    VStack {
                        HStack (alignment: .top, spacing: 0) {
                            Button(action: {
                                InviteMatchedGeometry = ""
                                isAHost = false
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .padding(.leading)
                                    .foregroundColor(.mainColor)
                                    .padding(.top, 14)
                            }
                            IndividualEvent(event: event, themeController: themeController)
                        }
                        .padding(.bottom, 40)
                        Spacer()
                    }
                }
                .frame(height: 130)
                ZStack {
                    ScrollView(showsIndicators: false) {
                        VStack (alignment: .leading) {
                            Text(isAHost ? "MAKE HOST" : "INVITE")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding(.leading)
                                .offset(y: -10)
                            
                            ForEach(friendsDictionary.friendsDictionary.values.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { item in
                                ZStack {
                                    // need to only show friends who are not already invited
                                    SelectIndividuals(id: item.id, selectedUser: $selectedUser, selected: selectedUser.contains(item.id) ? $trueBinding : $falseBinding, themeController: themeController)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 22)
                        
                    }
                    if selectedUser.isNotEmpty {
                        Button(action: {
                            InviteMatchedGeometry = ""
                            let nameOfSendingUser = friendsDictionary.friendsDictionary[currentUserID ?? ""]?.name ?? ""
                            var people = [Person]()
                            for item in selectedUser {
                                let person = friendsDictionary.friendsDictionary[item] ?? Person(id: "")
                                people.append(person)
                            }
                            if isAHost {
                                var userIDs = [String:String]()
                                for item in selectedUser {
                                    let token = friendsDictionary.friendsDictionary[item]?.token ?? ""
                                    userIDs[item] = token
                                }
                                for item in people {
                                    individualEvent.addHost(person: item )
                                }
                                functions.addEventHost(eventID: event.id, userID: userIDs, nameOfSendingUser: nameOfSendingUser, eventName: event.eventName)
                            } else {
                                for item in people {
                                    individualEvent.addInvited(person: item )
                                }
                                functions.sendEventInvitation(eventID: event.id, userID: selectedUser, nameOfSendingUser: nameOfSendingUser, eventName: event.eventName)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                isAHost = false
                            }
                        }) {
                            Text(isAHost ? "MAKE A HOST!" : "SEND INVITATION!" )
                                .font(.headline)
                                .foregroundColor(Color.black)
                                .padding()
                                .padding(.horizontal)
                                .background(themeController.theme.accent)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                        }
                        .offset(y: 100)
                    }
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct OpenedEventTabMenu: View {
    @Binding var isCalendarShowing: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 200, height: 45)
            .overlay(
                ZStack {
                    Rectangle()
                        .frame(width: 2, height: 45)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            isCalendarShowing = true
                        }) {
                            HStack {
                                ZStack {
                                    isCalendarShowing ? Color.speakerPurple : Color.mainColorInverse
                                    Image(systemName: "calendar")
                                        .font(.title)
                                        .foregroundColor(isCalendarShowing ? Color.mainColorInverse : Color.mainColor)
                                }
                            }
                        }
                        .frame(width: 100, height: 50)
                        Button(action: {
                            isCalendarShowing = false
                        }) {
                            HStack {
                                ZStack {
                                    isCalendarShowing ? Color.mainColorInverse : Color.speakerPurple
                                    Image(systemName: "bubble.middle.bottom")
                                        .font(.title)
                                        .foregroundColor(isCalendarShowing ? Color.mainColor : Color.mainColorInverse)
                                }
                            }
                        }
                        .frame(width: 100, height: 45)
                    }
                }
            )
            .cornerRadius(10)
            .shadow(color: Color.speakerPurple.opacity(0.4), radius: 4, x: 0, y: 0)
    }
}
struct OpenedEventTabMenu2: View {
    @Binding var isCalendarShowing: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
             .frame(width: 65, height: 100)
             .foregroundColor(Color.mainColorInverse.opacity(0.001))
             .overlay(
                 ZStack {

                     VStack(spacing: 0) {
                         Button(action: {
                             withAnimation {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .heavy)
        impactLight.impactOccurred()
#endif
                                 isCalendarShowing = true
                             }
                         }) {
                             ZStack {
                                 isCalendarShowing ? Color.backgroundColor : Color.mainColorInverse
                                 Image(systemName: "calendar")
                                     .font(isCalendarShowing ? .title : .title3)
                                     .foregroundColor(isCalendarShowing ? Color.black : Color.mainColor)
                                 }
                         }
                         .frame(width: 45, height: 50)
                         .cornerRadius(10, corners: [.topLeft, .topRight])

                         Button(action: {
                             withAnimation {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .heavy)
        impactLight.impactOccurred()
#endif
                                 isCalendarShowing = false
                             }
                         }) {
                             ZStack {
                                 isCalendarShowing != true ? Color.backgroundColor : Color.mainColorInverse
                                 Image(systemName: "bubble.middle.bottom")
                                     .font(isCalendarShowing ? .title3 : .title)
                                     .foregroundColor(isCalendarShowing != true  ? Color.mainColorInverse : Color.mainColor)
                                 }
                         }
                         .frame(width: 45, height: 50)
                         .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                     }
                 }
             )
             .cornerRadius(10)
             .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
    }
}
struct OpenedEventHeader: View {
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var functions: EventFunctions
    @ObservedObject var individualEvent: IndividualEventOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var event: EventModel
    @State var isFromConversation = false
    @Binding var EditEventMatchedGeometry: String
    @State var isFromRequests = false
    @Binding var NavigationMatchedGeomtry: String
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .ignoresSafeArea()
            VStack {
                HStack (alignment: .top, spacing: 0) {
                    Button(action: {
                        NavigationMatchedGeomtry = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .padding(.leading)
                            .foregroundColor(.black)
                            .padding(.top, 14)
                    }
                    IndividualEvent(event: event, themeController: themeController)
                    if isFromConversation != true && isFromRequests != true &&  individualEvent.hosts.firstIndex(where: {$0.id == currentUserID ?? ""}) != nil {
                        Button(action: {
                            EditEventMatchedGeometry = "0"
                        }) {
                            Image(systemName: "pencil")
                                .font(.title3)
                                .foregroundColor(Color.black)
                        }
                        .padding(.trailing)
                        .padding(.top, 20)
                    }
                }
                HStack (spacing: 50) {
                    Button(action: {
                        if individualEvent.isAttending != true {
                            let token = friendsDictionary.friendsDictionary[eventModel.eventInvitations[event.id] ?? ""]?.token ?? ""
                            let nameOfCurrentUser = friendsDictionary.friendsDictionary[currentUserID ?? ""]?.name ?? ""
                            functions.acceptEventInvitation(eventID: event.id, sentBy: eventModel.eventInvitations[event.id] ?? " ", sentByToken: token, nameOfSendingUser: nameOfCurrentUser, eventName: event.eventName)
                            individualEvent.attendEvent()
                            eventModel.removeEventInvitation(eventID: event.id)
                        }
                        
                    }) {
                        HStack (spacing: 3) {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeController.theme.accent)
                        }
                        Text("ATTENDING")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black)
                            .padding(5)
                            .background(individualEvent.isAttending ? themeController.theme.accent : Color.mainColorInverse.opacity(0.01))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {
                        if individualEvent.isNotAttending != true {
                            functions.declineEventInvitation(eventID: event.id)
                            individualEvent.notAttendingEvent()
                        }
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.red)
                        }
                        Text("NOT ATTENDING")
                            .foregroundColor(Color.black)
                            .fontWeight(.semibold)
                            .padding(5)
                            .background(individualEvent.isNotAttending ? themeController.theme.accent : Color.mainColorInverse.opacity(0.01))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .padding(.bottom, 5)
                .disabled(isFromRequests ? true : false)
                .opacity(isFromRequests ? 0 : 1)
            }
            .padding(.top, iOS15 ? 0 : 100)
//            .padding(.bottom, iOS15 ? 0 : 20)
        }
        .frame(height: 130)
        .padding(.top, iOS15 ? 0 : -50)
    }
}

struct EditEvent: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var functions: EventFunctions
    @State var month = "DEC"
    @State var day = ""
    @State var name: String
    @State var time = ""
    @State var description: String
    @State var location = ""
    @State var existingDate: Date
    @State var newDate: Date
    @State var eventID: String
    @State var eventTime: Timestamp
    @Binding var EditEventMatchedGeometry: String
    @StateObject var keyboard = KeyboardViewModel(showDismissAnimation: false)
    @State var allAttendingTokens: [String]
    @Binding var OpenedEventMatchedGeometry: String
    @State var showingAlert = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        return formatter
    }()
    let dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        return formatter
    }()
    let dateFormatter3: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        return formatter
    }()
    
    var body: some View {
        ZStack {
            themeController.theme.messageList
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    themeController.theme.primary
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        HStack (alignment: .top, spacing: 0) {
                            Button(action: {
                                EditEventMatchedGeometry = ""
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3.weight(.bold))
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                    .padding(.top, 14)
                            }
                            HStack (alignment: .top) {
                                IndividualDate2(date: $newDate, formatter2: dateFormatter2, formatter3: dateFormatter3, themeController: themeController)
                                VStack (alignment: .leading) {
                                    EventInformation2(name: $name, date: $newDate, formatter: dateFormatter)

                                }
                                Spacer()
                                if newDate != Date()  && name != "" {
                                    Button(action: {
                                        functions.updateEventDetails(oldStartTime: existingDate, newStartTime: newDate, eventName: name, eventDescription: description, location: location, eventID: eventID, allAttendingTokens: allAttendingTokens)
                                        eventModel.updateEventDummy(eventID: eventID, eventName: name, eventDescription: description, location: location, startTime: newDate, time: eventTime)
                                        EditEventMatchedGeometry = ""
                                        OpenedEventMatchedGeometry = ""
                                    }) {
                                        Image(systemName: "checkmark")
                                            .font(.largeTitle)
                                            .padding(.leading)
                                            .foregroundColor(.black)
                                            .padding(.trailing, 30)
                                            .padding(.top, 30)
                                    }
                                }
                            }
                            .padding(.leading, 10)
                            
                        }
                        .offset(y: -14)
//                        HStack {
//                            Text("ATTENDING")
//                                .fontWeight(.semibold)
//                                .foregroundColor(Color.black)
//                                .padding(5)
//                                .background(Color.accent)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                        }
//                        .padding(.horizontal)
//                        .padding(.vertical, 5)
//                        .padding(.bottom, 5)
//                        .hidden()
                        Spacer()
                    }
//                    .padding(.top, iOS15 ? 0 : 75)
//                    .padding(.bottom, iOS15 ? 0 : 20)
                }
                .frame(height: 130)
                .padding(.top, iOS15 ? 0 : -50)
                HStack {
                    VStack (alignment: .leading, spacing: 10) {
                        if keyboard.value == 0 {
                        VStack (alignment: .leading) {
                            HStack {
                                Text("TIME")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text("^")
                                    .font(.headline)
                                    .rotationEffect(Angle(degrees: 180))
                                    .padding(.bottom, 5)
                                Text("*")
                                    .foregroundColor(themeController.theme.accent)
                                    .offset(y: 3)
                                
                            }
                            .foregroundColor(.black)
                            DatePicker("Today", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                                .accentColor(themeController.theme.accent)
                                .labelsHidden()
                                .frame(height: 30)
                                .colorScheme(.light)
                                .padding(.bottom, 5)
                                .onAppear {
                                    UIDatePicker.appearance().minuteInterval = 5
                                }
                        }
                        }
                        Divider()
                        VStack (alignment: .leading) {
                            HStack {
                                Text("EVENT NAME")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text("^")
                                    .font(.headline)
                                    .rotationEffect(Angle(degrees: 180))
                                    .padding(.bottom, 7)
                                Text("*")
                                    .foregroundColor(themeController.theme.accent)
                                    .offset(y: 3)
                            }
                            HStack (spacing: 15) {
                                TextField("EVENT NAME", text: $name)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 10)
                            .background(Color.gray.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .foregroundColor(Color.black)
                        
                        Divider()
                        VStack (alignment: .leading) {
                            HStack {
                                Text("DESCRIPTION")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text("^")
                                    .font(.headline)
                                    .rotationEffect(Angle(degrees: 180))
                                    .padding(.bottom, 7)
                            }
                            HStack (spacing: 15) {
                                TextField("DESCRIPTION", text: $description)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 10)
                            .background(Color.gray.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .foregroundColor(Color.black)
                        
                        Divider()
                        VStack (alignment: .leading) {
                            HStack {
                                Text("LOCATION")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text("^")
                                    .font(.headline)
                                    .rotationEffect(Angle(degrees: 180))
                                    .padding(.bottom, 7)
                                
                            }
                            HStack (spacing: 15) {
                                TextField("LOCATION", text: $location)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 10)
                            .background(Color.gray.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .foregroundColor(Color.black)
                        
                        Divider()
    
                        
                    }
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, iOS15 ? 0 : 40)
                
                Spacer()
                Button(action: {
                    showingAlert.toggle()
                }) {
                    RoundedRectangle(cornerRadius: 17)
                        .frame(width: screenWidth - 95, height: 55)
                        .foregroundColor(Color.mainColorInverse.opacity(1))
                        .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
                        .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: screenWidth - 100, height: 50)
//                        .foregroundColor(colorScheme == .light ? .accent : .backgroundColor)
                        .foregroundColor(themeController.theme.primary)
                        .overlay(
                            Text("DELETE EVENT")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.mainColorInverse)
                        ))
                }
                .padding(.bottom, iOS15 ? 20 : 80)
            }
            .padding(.top, iOS15 ? 0 : 60)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure you want to delete this event?"),
                    primaryButton: .destructive(Text("Yes")) {
                        EditEventMatchedGeometry = ""
                        OpenedEventMatchedGeometry = ""
                        eventModel.removeEvent(eventID: eventID)
                        functions.deleteEvent(eventID: eventID, eventName: name)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct RequestToAttendEventButtons: View {
    @Binding var isRequestingToJoin: Bool
    @State var message = "Carson O'Sullivan is requesting to attend your event!"
    @State var isMessageShowing = false
    @ObservedObject var functions: EventFunctions
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var event: EventModel
    @Binding var OpenedEventMatchedGeometry: String
    @Binding var EventMatchedGeometryEffect: String
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            if isMessageShowing != true {
            VStack (spacing: 30) {
            Button(action: {
                isMessageShowing.toggle()
            }) {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: screenWidth - 95, height: 105)
                    .foregroundColor(Color.mainColorInverse.opacity(1))
                    .shadow(color: Color.mainColorInverse.opacity(0.4), radius: 20)
                    .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: screenWidth - 100, height: 100)
                    .foregroundColor(themeController.theme.accent.opacity(0.6))
                    .overlay(
                        Text("REQUEST TO JOIN")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.mainColorInverse)
                    ))
            }
                Button(action: {
                    isRequestingToJoin.toggle()
                    OpenedEventMatchedGeometry = ""
                    EventMatchedGeometryEffect = ""
                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: screenWidth - 195, height: 85)
                        .foregroundColor(Color.mainColorInverse.opacity(1))
                        .shadow(color: Color.mainColorInverse.opacity(0.4), radius: 20)
                        .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: screenWidth - 200, height: 80)
                        .foregroundColor(themeController.theme.accent.opacity(0.6))
                        .overlay(
                            Text("CANCEL")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.mainColorInverse)
                        ))
                }
            }
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: screenWidth - 45, height: 205)
                    .foregroundColor(Color.mainColorInverse.opacity(1))
                    .shadow(color: Color.mainColorInverse.opacity(0.4), radius: 20)
                    .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: screenWidth - 50, height: 200)
                    .foregroundColor(themeController.theme.accent.opacity(0.6))
                    .overlay(
                        ZStack {
                            VStack {
                                HStack {
                                    WebImage(url: friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.profilePicLink)
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                        .clipShape(Circle())
                                        .aspectRatio(contentMode: .fill)
                                    Text("\(friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.name ?? "")")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.mainColorInverse)
                                    Spacer()
                                }
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(Color.mainColorInverse)
                                    .frame(width: screenWidth - 80, height: 90)
                                    .padding(.top, -5)
                                    .overlay(
                                    TextEditor(text: $message)
                                    )
                                HStack {
                                    Button(action: {
                                        withAnimation() {
                                        isMessageShowing.toggle()
                                        }
                                    }){
                                    RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(Color.mainColorInverse.opacity(0.1))
                                        .frame(width: 80, height: 40)
                                        .overlay(
                                            Text("Cancel")
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.mainColorInverse)
                                        )
                                    }
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                        isMessageShowing.toggle()
                                        isRequestingToJoin = false
                                        OpenedEventMatchedGeometry = ""
                                        EventMatchedGeometryEffect = ""
                                        }

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        functions.requestToJoinEvent(eventID: event.id, sentByToken: friendsDictionary.friendsDictionary[currentUserID ?? ""]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[currentUserID ?? ""]?.name ?? "", eventName: event.eventName, message: message)
                                        }
                                    }){
                                    RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(Color.mainColorInverse.opacity(0.2))
                                        .frame(width: 80, height: 40)
                                        .overlay(
                                            Text("Send")
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.mainColorInverse)
                                        )
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                            .frame(width: screenWidth - 80, height: 200, alignment: .top)
                            .padding(.horizontal)
                    ))

            }
        }
    }
}

struct EventJoinRequests: View {
    @Binding var JoinRequestMatchedGeometry: String
    @StateObject var requests = IndividualEventRequestedUsersOO(eventID: "", friendsDictionary: FriendsDictionary())
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            if requests.eventRequest.isNotEmpty {
        Button(action: {
            JoinRequestMatchedGeometry = "0"
        }) {
        HStack {
       RoundedRectangle(cornerRadius: 12)
            .foregroundColor(Color.mainColorInverse)
            .frame(width: screenWidth/2, height: 39)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: (screenWidth/2) - 2, height: 37)
                        .foregroundColor(themeController.theme.accent.opacity(1))
                        .overlay(
                            ZStack {
                                Text("\(requests.eventRequest.count == 1 ? "1 JOIN REQUEST" : "\(requests.eventRequest.count) JOIN REQUESTS")")
                                    .foregroundColor(Color.mainColorInverse)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        )
                }
            )
            Spacer()
        }
        }
        .padding(.top, 15)
        .padding(.leading, 10)
        .animation(.linear(duration: 0.3))
        }
        }
    }
}

struct EventJoinRequestsHome: View {
    @Binding var JoinRequestMatchedGeometry: String
    @ObservedObject var requests: IndividualEventRequestedUsersOO
    @ObservedObject var eventModel: EventModelOO
    @State var event: EventModel
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var functions: EventFunctions
    @ObservedObject var individualEvent: IndividualEventOO
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            VStack {
                OpenedEventHeader(eventModel: eventModel, functions: functions, individualEvent: individualEvent, friendsDictionary: friendsDictionary, event: event, EditEventMatchedGeometry: .constant(""), isFromRequests: true, NavigationMatchedGeomtry: $JoinRequestMatchedGeometry, themeController: themeController)
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(Array(requests.eventRequest.values), id: \.self) { item in
                            VStack {
                                HStack {
                                    WebImage(url: item.person.webLink)
                                        .resizable()
                                        .scaledToFill()                                      .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                    Text(item.person.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                    HStack(spacing: 40) {
                                        Button(action: {
                        #if os(iOS)
                                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                                impactLight.impactOccurred()
                        #endif
                                            requests.removeRequest(id: item.id)
                                            functions.declineEventRequest(eventID: event.id, userID: item.id)
                                        }) {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(themeController.theme.accent.opacity(0.1))
                                                .overlay(
                                            Image(systemName: "multiply")
                                                .foregroundColor(Color.red)
                                                .font(.title3)
                                            )
                                        }
                                        Button(action: {
                                            individualEvent.addAttending(id: item.id, person: item.person)
                                            requests.removeRequest(id: item.id)
                                            functions.acceptEventRequest(eventID: event.id, token: item.token, eventName: event.eventName, userID: item.id)
                        #if os(iOS)
                                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                                impactLight.impactOccurred()
                        #endif
                                        }) {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(Color.blue.opacity(0.1))
                                                .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.title3)
                                            )
                                        }
                                    }
                                }
                                HStack {
                                    Text(item.message)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                                Rectangle()
                                    .frame(width: screenWidth - 30, height: 2)
                                    .foregroundColor(themeController.theme.primary.opacity(0.2))
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.top, iOS15 ? 0 : 50)
                Spacer()

            }
            .padding(.top, iOS15 ? 0 : 60)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct EventJoinRequestsHomeTabView: View {
    @Binding var JoinRequestMatchedGeometry: String
    @ObservedObject var requests: IndividualEventRequestedUsersOO
    @ObservedObject var eventModel: EventModelOO
    @State var event: EventModel
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var functions: EventFunctions
    @ObservedObject var individualEvent: IndividualEventOO
    @ObservedObject var themeController: ThemeController
    @State var selectedTab = "NewConversation"
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    EventJoinRequestsHome(JoinRequestMatchedGeometry: $JoinRequestMatchedGeometry, requests: requests, eventModel: eventModel, event: event, friendsDictionary: friendsDictionary, functions: functions, individualEvent: individualEvent,themeController: themeController)
                        .tag("NewConversation")
                }
                .edgesIgnoringSafeArea(.bottom)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    JoinRequestMatchedGeometry = ""
                }
        }
        
    }
}
