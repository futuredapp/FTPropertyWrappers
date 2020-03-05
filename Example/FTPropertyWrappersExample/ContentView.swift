import SwiftUI
import FTPropertyWrappers

struct ContentView: View {

    struct Hidden: Codable {
        var age: Int
        var powerLevel: UInt64
    }

    @GenericPassword(
        service: "app.futured.ftpropertywrappers.example.name",
        account: "example@futred.com",
        refreshPolicy: .manual,
        accessOption: kSecAttrAccessibleWhenUnlocked,
        accessFlags: [.biometryAny, .or, .devicePasscode]
    ) var data: Hidden?

    @State var log: String = ""
    @State var numberOfSaves: Int = 0

    var body: some View {

        VStack {
            Text(log)
            HStack(alignment: .center, spacing: 10) {
                Button(action: {
                    do {
                        try self._data.loadFromKeychain()
                        if let data = self.data {
                            self.log += "Loaded: Age: \(data.age), PL: \(data.powerLevel)\n"
                        } else {
                            self.log += "Loaded: <null>\n"
                        }
                    } catch {
                        self.log += "\(error.localizedDescription)\n"
                    }
                }) {
                    Text("Load")
                }
                Button(action: {
                    do {
                        self.numberOfSaves += 1
                        self.data = Hidden(age: self.numberOfSaves, powerLevel: self.data?.powerLevel ?? UInt64.random(in: 0...9001))
                        try self._data.saveToKeychain()
                        self.log += "Saved: Age: \(self.data!.age), PL: \(self.data!.powerLevel)\n"
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
