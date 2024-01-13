import SwiftUI


struct GafferDetailsView: View {
    var gaffer: User

    var body: some View {
        ScrollView {
            
            VStack {
                Spacer()
                Text("Profession: \(gaffer.profession)")
                    .font(.headline)
                    .padding(.bottom, 5)

                Text("Owns Kit: \(gaffer.ownKit ? "Yes" : "No")")
                    .font(.subheadline)
                    .foregroundColor(gaffer.ownKit ? .green : .red)
                    .padding(.bottom, 5)
                
                Text("Beauty Lights: \(gaffer.beautyLights ? "Yes" : "No")")
                    .font(.subheadline)
                    .foregroundColor(gaffer.beautyLights ? .green : .red)
                    .padding(.bottom, 5)
                
                Text("Practical Lights: \(gaffer.practicalLights ? "Yes" : "No")")
                    .font(.subheadline)
                    .foregroundColor(gaffer.practicalLights ? .green : .red)
                    .padding(.bottom, 5)
                
                Text("External Lights: \(gaffer.externalLights ? "Yes" : "No")")
                    .font(.subheadline)
                    .foregroundColor(gaffer.externalLights ? .green : .red)
                    .padding(.bottom, 5)
                Text("Flash Experience: \(gaffer.flashExp ? "Yes" : "No")")
                    .font(.subheadline)
                    .foregroundColor(gaffer.flashExp ? .green : .red)
                    .padding(.bottom, 5)

                // Add more details if needed

                Spacer()
            }
           
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            
            
        }
        .navigationBarTitle(gaffer.name)
    }
}
#Preview {
    GafferDetailsView(gaffer: User(name: "Tom",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true))
}
