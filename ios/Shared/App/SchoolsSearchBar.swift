//
//  SchoolsTest.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 7/12/21.
//

import SwiftUI

struct SchoolsSearchBar: View {
    var schools: [School] = Bundle.main.decode("schools.json")
    @Binding var selectedSchool: String
    @State var selected: String = ""
    @State var isScrollExpanded = false
    @State var text = ""
    var body: some View {
        HStack {
            Spacer()
            VStack (alignment: .trailing) {

                    HStack(spacing: 15) {

                        if selected != "" {
                            HStack (alignment: .top) {
//                            ZStack {
                            Text(selected)
                                .padding(.leading)
                                Button(action: {
                                    selectedSchool = ""
                                    selected = ""
                                    text = ""
                                }){
                                    Image(systemName: "clear")
                                        .font(.headline)
                                        .foregroundColor(.mainColor)
                                        .opacity(0.2)
                                } // BUTTON
//                                .offset(x: 90)
//                            }
                                Spacer()
                            }
                        } else {
                            TextField("University of Toronto", text: self.$text)
//                            Divider()\
                                .padding(.leading)
                        }
                        
                    }// HSTACK
                    .frame(width: screenWidth/2)
                    .padding(.horizontal, -16)

                if text != "" && selectedSchool == ""  {
                    ScrollView(showsIndicators: false) {
                        LazyVStack (alignment: .center) {
                            ForEach(schools.filter{$0.school.lowercased().contains(self.text.lowercased())}, id: \.self) { item in
                                IndividualSchoolItem(school: item.school)
                                    .frame(width: screenWidth/2)
                                    .onTapGesture {
                                     selectedSchool = item.school
                                        selected = item.school
                                    }
                            }
                        }
//                        .offset(x: phoneWidth/6)
                        .padding(.top, 5)
                    }
                }
                Spacer()
            }
        }
        
    }
}

struct IndividualSchoolItem: View {
    @State var school: String
    var body: some View {
        HStack {
            Text(school)
                .font(.subheadline)
                .fontWeight(.bold)
              .foregroundColor(Color.mainColor)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
        Divider()
    }
}

