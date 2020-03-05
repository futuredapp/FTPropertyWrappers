import SwiftUI
import FTPropertyWrappers

struct ContentView: View {

    // Codable structure that will be used for storing values in keychain
    struct Hidden: Codable, CustomDebugStringConvertible {
        var debugDescription: String {
            return "Text: \(text), Number: \(number), Updates: \(numberOfUpdates)"
        }

        // Text inserted by user
        var text: String

        // Number inserted by user
        var number: Int

        // Number of updates since last deletion counted by application
        var numberOfUpdates: UInt64
    }

    // Generic password with Access Control. Notice, that refresh policy is manual. This is recommended when Access Conrol is used.
    @GenericPassword(
        service: "app.futured.ftpropertywrappers.example.name",
        account: "example@futred.com",
        refreshPolicy: .manual,
        // Visit Apple's documentation to learn more about following value
        accessOption: kSecAttrAccessibleWhenUnlocked,
        // Following combination should use any biometry with fallback for device passcode (though this behavior may be default for biometry option).
        accessFlags: [.biometryAny, .or, .devicePasscode]
    ) var data: Hidden?

    // State stroring output
    @State var log: String = ""

    // Field for user-input string (using TextField)
    @State var text: String = ""
    // Field for user-input number (using stepper)
    @State var number: Int = 0

    // Field for number of saves since last deletion
    @State var numberOfUpdates: UInt64 = 0

    var body: some View {
        VStack {
            VStack {
                HStack {
                    TextField("Enter text", text: $text).background(Color.gray)
                    Stepper("", value: $number)
                    Text("\(number)")
                }
                HStack(alignment: .center, spacing: 10) {
                    Button(action: load) {
                        Text("Load")
                    }
                    Button(action: save) {
                        Text("Save")
                    }
                    Button(action: delete) {
                        Text("Delete")
                    }
                    Button(action: clean) {
                        Text("Clean Log")
                    }
                    Button(action: hideKeyboard) {
                        Text("HideKeyboard")
                    }
                }
            }
            Text(log)
        }
    }

    func save() {
        do {
            self.numberOfUpdates += 1
            self.data = Hidden(text: text,
                               number: number,
                               numberOfUpdates: numberOfUpdates)
            // In manual mode, data are not stored into keychain after updates to wrapped property, therefore we have to save data manually.
            try self._data.saveToKeychain()
            self.log += "[Saved] \(data!)\n"
        } catch {
            self.log += "\(error.localizedDescription)\n"
        }
    }

    func load() {
        do {
            try self._data.loadFromKeychain()
            if let data = self.data {
                self.log += "[Loaded] \(data)\n"
            } else {
                self.log += "Loaded: <null>\n"
            }
        } catch {
            self.log += "\(error.localizedDescription)\n"
        }
    }

    func delete() {
        do {
            try self._data.deleteKeychain()
            self.log += "[deleted]\n"
            self.numberOfUpdates = 0
        } catch {
            self.log += "\(error.localizedDescription)\n"
        }
    }

    // Following support for UI
    func clean() {
        self.log = ""
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
