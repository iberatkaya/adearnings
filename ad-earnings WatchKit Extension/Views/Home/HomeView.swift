import SwiftUI

struct HomeView: View {
    @EnvironmentObject var connectivityController: ConnectivityController
    
    @State var fetching: Bool = false
    
    
    var body: some View {
        if(fetching){
            VStack{
                Text("Fetching")
                ProgressView()
            }
        }
        else {
            VStack {
                Text("Welcome")
                Button(action: {
                    connectivityController.session?.sendMessage(["data": "requestWeek"], replyHandler: nil, errorHandler: nil)
                }){
                    Text("Send message")
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
