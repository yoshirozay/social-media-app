//
//  CreateEvent.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 8/4/22.
//

import SwiftUI

struct CreateEvent: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var event: EventModelOO
    @State var month = "DEC"
    @State var day = ""
    @Binding var name: String
    @State var time = ""
    @Binding var description: String
    @State var location = ""
    @Binding var date: Date
    @Binding var dateEnd: Date
    @State var InviteToEventMatchedGeometry: String = ""
    @Binding var CreateEventMatchedGeometry: String
    @StateObject var keyboard = KeyboardViewModel(showDismissAnimation: false)
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
            VStack {
                ZStack {
                    themeController.theme.primary
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        HStack (alignment: .top, spacing: 0) {
                            Button(action: {
                                withAnimation {
                                    CreateEventMatchedGeometry = ""
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3.weight(.bold))
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                    .padding(.top, 6)
                            }
                            HStack (alignment: .top) {
                                IndividualDate2(date: $date, formatter2: dateFormatter2, formatter3: dateFormatter3, themeController: themeController)
                                VStack (alignment: .leading) {
                                    EventInformation2(name: $name, date: $date, formatter: dateFormatter)
                                    //                                    EventAttendees(attendees: event.attendees)
                                }
                                Spacer()
                                if date != Date()  && name != "" {
                                    Button(action: {
                                        InviteToEventMatchedGeometry = "0"
                                        hideKeyboard()
                                    }) {
                                        Image(systemName: "chevron.right")
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
                        Spacer()
                    }
                    .padding(.top, iOS15 ? 0 : 80)
                    .padding(.bottom, iOS15 ? 0 : 20)
                    //                    .padding(.horizontal, 10)
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
                            
                            DatePicker("Today", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .accentColor(themeController.theme.accent)
                                .foregroundColor(.black)
                                .labelsHidden()
                                .frame(height: 30)
                                .padding(.bottom, 5)
                                .colorScheme(.light)
                                .onAppear {
                                    UIDatePicker.appearance().minuteInterval = 5
//                                    UIDatePicker.appearance().c
                                }
                            
                        }
                        .foregroundColor(Color.black)
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
                
            }
            .padding(.top, iOS15 ? 0 : 16)
            if InviteToEventMatchedGeometry != "" {
                InviteToCreatedEventTabView(InviteToEventMatchedGeometry: $InviteToEventMatchedGeometry, name: $name, eventDescription: $description, date: $date, dateEnd: $dateEnd, CreateEventMatchedGeometry: $CreateEventMatchedGeometry, location: $location, friendsDictionary: friendsDictionary, event: event, themeController: themeController)
            }
        }
    }
}

struct CreateEventTabView: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var event: EventModelOO
    @Binding var CreateEventMatchedGeometry: String
    @Binding var name: String
    @Binding var eventDescription: String
    @Binding var date: Date
    @Binding var dateEnd: Date
    @State var selectedTab = "NewConversation"
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    CreateEvent(friendsDictionary: friendsDictionary, event: event, name: $name, description: $eventDescription, date: $date, dateEnd: $dateEnd, CreateEventMatchedGeometry: $CreateEventMatchedGeometry, themeController: themeController)
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
                    CreateEventMatchedGeometry = ""
                }
        }
        
    }
}


struct EventInformation2: View {
    @Binding var name: String
    @Binding var date: Date
    @State var formatter: DateFormatter
    var body: some View {
        Text(name == "" ? "TBD" : name)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top)
            .offset(x: -1)
            .foregroundColor(.black)
        Text("\(date, formatter: formatter)")
            .foregroundColor(.black)
    }
}
struct IndividualDate2: View {
    @Binding var date: Date
    @State var formatter2: DateFormatter
    @State var formatter3: DateFormatter
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.accent
            ZStack {
                themeController.theme.primary
                VStack (spacing: 0) {
                    Text("\(date, formatter: formatter2)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    Rectangle()
                        .frame(width: 60, height: 2)
                        .foregroundColor(.black)
                    
                    Text("\(date, formatter: formatter3)")
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


struct InviteToCreatedEvent: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var falseBinding = false
    @State var trueBinding = true
    @State var selectedUser = [String]()
    @Binding var name: String
    @Binding var eventDescription: String
    @Binding var date: Date
    @Binding var dateEnd: Date
    @State var showingAlert = false
    @Binding var InviteToEventMatchedGeometry: String
    @Binding var CreateEventMatchedGeometry: String
    @StateObject var functions = EventFunctions()
    @State var location: String
    @ObservedObject var event: EventModelOO
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
                .ignoresSafeArea(.all)
            VStack {
                VStack {
                    ZStack {
                        themeController.theme.primary
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            HStack (alignment: .top, spacing: 0) {
                                Button(action: {
                                    InviteToEventMatchedGeometry = ""
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.title3.weight(.bold))
                                        .padding(.leading)
                                        .foregroundColor(.black)
                                        .padding(.top, 14)
                                }
                                HStack (alignment: .top) {
                                    IndividualDate2(date: $date, formatter2: dateFormatter2, formatter3: dateFormatter3, themeController: themeController)
                                    VStack (alignment: .leading) {
                                        EventInformation2(name: $name, date: $date, formatter: dateFormatter)
                                        //                                    EventAttendees(attendees: event.attendees)
                                    }
                                    Spacer()
                                    
                                    Button(action: {
                                        showingAlert = true
                                        
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .font(.largeTitle)
                                            .padding(.leading)
                                            .foregroundColor(.black)
                                            .padding(.trailing, 30)
                                            .padding(.top, 30)
                                    }
                                }
                                .padding(.leading, 10)
                                
                            }
                            Spacer()
                        }
                        .padding(.top, iOS15 ? 0 : 80)
                        .padding(.bottom, iOS15 ? 0 : 20)
                        //                    .padding(.horizontal, 10)
                    }
                    .frame(height: 130)
                    .padding(.top, iOS15 ? 0 : -50)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text("INVITE")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(.leading)
                            .offset(y: -10)
                            .foregroundColor(.black)
                        
                        ForEach(friendsDictionary.friendsDictionary.values.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { item in
                            
                            SelectIndividuals(id: item.id, selectedUser: $selectedUser, selected: selectedUser.contains(item.id) ? $trueBinding : $falseBinding, themeController: themeController)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 22)
                }
                .padding(.top, iOS15 ? 0 : 40)
                Spacer()
            }
            .padding(.top, iOS15 ? 0 : 60)
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Create \"\(name)\"?"),
                    primaryButton: .destructive(Text("Yes")) {
                        let eventID = UUID().uuidString
                        event.createTempEvent(startTime: date, eventName: name, eventDescription: eventDescription, invitedUsers: selectedUser, hostIDs: [], location: location, nameOfSendingUser: friendsDictionary.friendsDictionary[currentUserID ?? ""]?.name ?? "", eventID: eventID)
                        functions.createEvent(startTime: date, eventName: name, eventDescription: eventDescription, invitedUsers: selectedUser, hostIDs: [], location: location, nameOfSendingUser: friendsDictionary.friendsDictionary[currentUserID ?? ""]?.name ?? "", eventID: eventID)
                        InviteToEventMatchedGeometry = ""
                        CreateEventMatchedGeometry = ""
                        name = ""
                        eventDescription = ""
                        location = ""
                        date = Date()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct InviteToCreatedEventTabView: View {
    @Binding var InviteToEventMatchedGeometry: String
    @Binding var name: String
    @Binding var eventDescription: String
    @Binding var date: Date
    @Binding var dateEnd: Date
    @State var selectedTab = "NewConversation"
    @Binding var CreateEventMatchedGeometry: String
    @Binding var location: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var event: EventModelOO
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    InviteToCreatedEvent(friendsDictionary: friendsDictionary, name: $name, eventDescription: $eventDescription, date: $date, dateEnd: $dateEnd, InviteToEventMatchedGeometry: $InviteToEventMatchedGeometry, CreateEventMatchedGeometry: $CreateEventMatchedGeometry, location: location, event: event, themeController: themeController)
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
                    InviteToEventMatchedGeometry = ""
                }
        }
        
    }
}

