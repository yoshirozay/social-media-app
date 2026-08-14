//
//  SearchForSomeone.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/14/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Introspect

struct SearchForSomeone: View {
    @State var search = false
    @State var text = ""
    @Binding var StrangerProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedItem: Person!
    @StateObject var findPeople = FindPeopleOO()
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var friendsDictionary: FriendsDictionary
    var body: some View {
        
        ZStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color.mainColor.opacity(0.3))
                    TextField("Find Someone", text: self.$text)
                        .disableAutocorrection(true)

#if os(macOS)
                    .textFieldStyle(.plain)
#endif
                    if self.text.isNotEmpty {
                        Button(action: {
                            findPeople.search(username: text)
                            search = true
                            hideKeyboard()
                        }){
                            Text("GO")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .opacity(colorScheme == .light ? 0.2 : 0.5)
                        } // BUTTON
                        .buttonStyle(.borderless)
                    }
                }// HSTACK
                .frame(height: 30)
                .padding(10)
                .background(Color.mainColor.opacity(colorScheme == .light ? 0.03 : 0.07))
                .cornerRadius(10)
//                .shadow(radius: 2, x: 0, y: 1)
                .padding(.trailing, 16)
                .padding(.leading, 16)
                
                ZStack{
                    if findPeople.isSearching {
                        HStack( spacing: 20){
//                            Text("...")
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                        }
                    }else if findPeople.people.isNotEmpty {
                        SearchForSomeOneData(StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry,
                                             StrangerProfileSelectedItem: $StrangerProfileSelectedItem,
                                             people: findPeople, friendsDictionary: friendsDictionary)
                    }
                }.animation(.easeInOut(duration: 0.3)) 
            }
        }
    }
}
struct SearchForStranger: View {
    @State var search = false
    @State var text = ""
    @Binding var StrangerProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedItem: Person!
    @StateObject var findPeople = FindPeopleOO()
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var FriendProfileMatchedGeometry: String

    var body: some View {
        
        ZStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color.mainColor.opacity(0.3))
                    TextField("Look up a username", text: self.$text)
                        .contentShape(Rectangle())
                        .font(.subheadline)
                        .foregroundColor(Color.black)
                        .disableAutocorrection(true)
                        .onChange(of: self.text) { _ in
                            findPeople.search(username: text)
                            if self.text == "" {
                                findPeople.clearPerson()
                            }
                        }
#if os(macOS)
                        .textFieldStyle(.plain)
#endif

                }// HSTACK
                .frame(height: 30)
                .padding(10)
                .background(themeController.theme.secondary)
                .cornerRadius(10)
                .padding(.horizontal)
                VStack {
                    ZStack{
                        if findPeople.isSearching {
                            HStack( spacing: 20){

                            }
                        }else if findPeople.people.isNotEmpty {
                            SearchForSomeOneData(StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry,
                                                 StrangerProfileSelectedItem: $StrangerProfileSelectedItem,
                                                 people: findPeople, friendsDictionary: friendsDictionary)
                        }
                    }
                    if text.count > 1 {
                        LazyVStack {
                            ForEach(friendsDictionary.friendsDictionary.values.filter({$0.name.lowercased().contains(text.lowercased())}), id: \.self) { item in
                                if item.id != TristanUserID {
                                    SearchForSomeoneResults(person: item)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            hideKeyboard()
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                FriendProfileMatchedGeometry = item.id
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
struct SearchForSomeOneData: View {
    @Namespace var namespace
    @Binding var StrangerProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedItem: Person!
    @ObservedObject var people : FindPeopleOO
    @StateObject var keyboard = KeyboardOO()
    @ObservedObject var friendsDictionary: FriendsDictionary
    var body: some View {
        
        ForEach(people.people, id: \.self){ item in
            if friendsDictionary.friendsDictionary[item.id] == nil {
                SearchForSomeoneResults(person: item)
                    .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                        withAnimation(.easeIn(duration: 0.3)) {
                            StrangerProfileMatchedGeometry = "0"
                            StrangerProfileSelectedItem = item
                            people.clearPerson()
                        }
                    }
            }
//                .padding(.bottom, 20)
        }
        
    }
}

struct SearchForSomeoneResults: View {
    @State var person: Person
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 59, height: 59)
                    .foregroundColor(person.profileCircle)
//                                .foregroundColor(Color.mainColor)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
            WebImage(url: person.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 12) {
                Text(person.name)
                    .fontWeight(.bold)
                Text(person.username)
                    .font(.caption)
                    .padding(.top, -10)
            } // VSTACK
           .foregroundColor(Color.black)
            Spacer()
        } // HSTACK
        .padding(.horizontal)
//        Divider()
//        .padding(.horizontal)
        
    }
}

