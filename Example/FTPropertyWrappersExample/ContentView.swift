import SwiftUI
import FTPropertyWrappers

struct ContentView: View {
/*
    @GenericPassword(
        service: "app.futured.ftpropertywrappers.example.name",
        account: "example@futred.com",
        refreshPolicy: .manual
    ) var myName: String?
*/
    struct Hidden: Codable {
        var age: Int
        var powerLevel: UInt64
    }

    @GenericPassword var data: Hidden?

    init() {
        _data = try! GenericPassword<Hidden>(
            serviceIdentifier: "app.futured.ftpropertywrappers.example.data",
            account: "example@futred.com", refreshPolicy: .manual,
            protection: (access: .whenUnlocked, flags: [.biometryAny, .or, .devicePasscode])
        )
    }

    @State var log: String = ""
    @State var numberOfSaves: Int = 0

    var body: some View {
        VStack {
            Text(log)
            HStack(alignment: .center, spacing: 10) {
                Button(action: {
                    do {
                        try self._data.loadFromKeychain()
                        self.log += "Age: \(self.data!.age), PL: \(self.data!.powerLevel)\n"
                    } catch {
                        self.log += "\(error.localizedDescription)\n"
                    }
                }) {
                    Text("Load")
                }
                Button(action: {
                    do {
                        self.data?.age = self.numberOfSaves
                        try self._data.saveToKeychain()
                    } catch {
                        self.log += "\(error.localizedDescription)\n"
                    }
                }) {
                    Text("Save")
                }
                Button(action: {
                    do {
                        try self._data.deleteKeychain()
                        self.log += "<deleted>\n"
                        self.numberOfSaves = 0
                    } catch {
                        self.log += "\(error.localizedDescription)\n"
                    }
                }) {
                    Text("Delete")
                }
                Button(action: {
                    self.log = ""
                }) {
                    Text("Clean Log")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
