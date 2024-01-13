import SwiftUI

struct GafferList: View {
    var gaffers: [User] = DataService().getData()
    
    var body: some View {
        VStack{
            Text("Gaffer Directory")
            NavigationView {
                List(gaffers) { gaffer in
                    NavigationLink(destination: GafferDetailsView(gaffer: gaffer)) {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack {
                                    // Use a default image name or handle nil case
                                }
                                Spacer()
                                VStack {
                                    Text(gaffer.name)
                                        .font(.headline)
                                    Text(gaffer.profession)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct GafferList_Previews: PreviewProvider {
    static var previews: some View {
        GafferList(gaffers: [
            User(name: "John Doe", profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true),
            User(name: "Jane Smith", profession: "Assistant Gaffer", ownKit: false, flashExp: true, beautyLights: true, externalLights: false, practicalLights: true)
        ])
    }
}
