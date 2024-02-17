////
////  PlayersListView.swift
////  dynamoxQuiz
////
////  Created by GIRA on 16/02/24.
////
//import SwiftUI
//import RealmSwift
//
//struct PlayersListView: View {
//    @ObservedRealmObject var playersHistory: PlayersHistory
//
//    /// The button to be displayed on the top left.
//    var leadingBarButton: AnyView?
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // The list shows the items in the realm.
//                List {
//                    ForEach(playersHistory.players) { player in
//                        PlayerRow(player: player)
//                    }.onDelete(perform: $playersHistory.players.remove)
//                }
//                .listStyle(GroupedListStyle())
//                    .navigationBarTitle("Items", displayMode: .large)
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarItems(
//                        leading: self.leadingBarButton,
//                        // Edit button on the right to enable rearranging items
//                        trailing: EditButton())
//                // Action bar at bottom contains Add button.
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        // The bound collection automatically
//                        // handles write transactions, so we can
//                        // append directly to it.
//                        $playersHistory.players.append(PlayerDb(name: "Teste", firstScore: 8))
//                    }) { Image(systemName: "plus") }
//                }.padding()
//            }
//        }
//    }
//}
//
///// Represents an Item in a list.
//struct PlayerRow: View {
//    @ObservedRealmObject var player: PlayerDb
//
//    var body: some View {
//        // You can click an item in the list to navigate to an edit details screen.
//        NavigationLink(destination: PlayerDetailsView(player: player)) {
//            Text(player.name)
//        }
//    }
//}
//
///// Represents a screen where you can edit the item's name.
//struct PlayerDetailsView: View {
//    @ObservedRealmObject var player: PlayerDb
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Enter a new name:")
//            // Accept a new name
//            TextField("New name", text: $player.name)
//                .navigationBarTitle(player.name)
//        }.padding()
//    }
//}
//
