import SwiftUI

struct ContentView: View {
    @ObservedObject var connectivityController: ConnectivityController
    
    init() {
        connectivityController = ConnectivityController()
    }
    
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
