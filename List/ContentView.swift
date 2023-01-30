
import SwiftUI
import CoreData
import Combine
struct ContentView: View {
    @State var name = String()
    @State var Age = Int()
    @State var adress = String()
    @State var isEditing: EditMode = .inactive
    @State var switchBetween = false
    @ObservedObject var chip = UserSetting()
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @State var data = Int()
    var today = Date()
    @State private var phone = "+7"
    
    static let weekDayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 3)
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    
    var body: some View {
        
        VStack{
            
            RegistrationView()
            
        }
        
        ListView()
            .opacity(-1)
            .frame(width: status ? 0 : 0, height: 0)
    }
}
struct RegistrationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \ListItems.rowOrder, ascending: true)], animation:.default)
    
    private var myItems: FetchedResults<ListItems>
    @State var name = String()
    @State var Age = Int()
    @State var adress = String()
    @State var isEditing: EditMode = .inactive
    @State var switchBetween = false
    @ObservedObject var chip = UserSetting()
    @Environment (\.presentationMode) var List
    @State var data = Int()
    var today = Date()
    @State private var phone = "+7"
    @State var status = false
    static let weekDayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 3)
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        
        Text("Регистрация")
        
            .font(.largeTitle)
            .foregroundColor(.red)
            .opacity(0.5)
            .padding()
            .padding()
        VStack{
            Form{
                VStack (spacing: 20) {
                    
                    TextField("Введите имя", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Stepper("Введите возраст: \(Age)", value: $Age)
                        .padding(.leading, 22)
                        .opacity(0.4)
                    
                    
                    
                    Toggle(isOn: self.$chip.isOn){
                        Text(chip.isOn ? "чипировался" : "не чипировался")
                            .padding(.leading, 22)
                            .opacity(0.4)
                        
                        
                        
                    }
                    Spacer()
                        .fixedSize()
                    
                    
                    TextField("Введите номер", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)
                        .onReceive(Just(phone)) { newValue in
                            let filtered = newValue.filter { "+0123456789".contains($0) }
                            if filtered != newValue {
                                self.phone = filtered
                            }
                        }
                    
                    TextField("Введите адрес", text: $adress, onCommit:{
                        adress = ""
                        
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    
                }
                
            }
            Button("Добавить чувака")
            {
                self.status.toggle()
                
                
                if name != "" && adress != ""
                    
                    
                {
                    let itemtoSave = ListItems(context: self.viewContext)
                    itemtoSave.id = UUID()
                    itemtoSave.itemName = (chip.isOn ?
                                           "имя: \(name), возраст: \(Age), чипирован, адрес: \(adress), phone: \(phone), Data \(today)" :
                                            
                                            "имя: \(name), возраст: \(Age), не чипирован, адрес: \(adress), phone: \(phone), Data \(today)")
                    itemtoSave.rowOrder = (myItems.last?.rowOrder ?? 0) + 1
                    try? self.viewContext.save()
                    name = ""
                    adress = ""
                    Age = 0
                    chip.isOn = false
                    phone = "+7"
                    
                    
                }
                
                
                
            }
            .foregroundColor(.red)
            .opacity(0.6)
            .font(.body)
            
            
            
            .sheet (isPresented: $status){
                ListView()
                
            }
        }}}

struct ListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors:
                    [NSSortDescriptor(keyPath: \ListItems.rowOrder, ascending: true)])
    private var myItems: FetchedResults<ListItems>
    
    
    @State var switchBetween = false
    @ObservedObject var chip = UserSetting()
    @State var isEditing: EditMode = .inactive
    @State var data = Int()
    var today = Date()
    @State private var phone = "+7"
    
    static let weekDayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 3)
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        
        
        Button(action: {
            switchBetween.toggle()
            if switchBetween == true{
                isEditing = .active
            }
            else{
                isEditing = .inactive
            }
        }, label: {
            Text("Редактировать")
                .padding()
        })
        List {
            ForEach(myItems, id: \.id) {
                addToList in Text("\(addToList.itemName ?? "Имя")")
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
            .font(.system(size: 20))
            
        }
        .environment(\.editMode, .constant(isEditing))
    }
    private func delete(at offsets: IndexSet){
        for offset in offsets {
            let itemName = myItems[offset]
            viewContext.delete(itemName)
            saveData()
        }
    }
    private func saveData() {
        try? self.viewContext.save()
    }
    private func move(from sourse: IndexSet, to destination: Int){
        if sourse.first! > destination{
            myItems[sourse.first!].rowOrder = myItems[destination].rowOrder - 1
            for i in destination...myItems.count - 1{
                myItems[i].rowOrder = myItems[i].rowOrder + 1
            }
        }
        if sourse.first! < destination {
            myItems[sourse.first!].rowOrder = myItems[destination-1].rowOrder + 1
            for i in 0...destination-1 {
                myItems[1].rowOrder = myItems[i].rowOrder - 1
            }
        }
        saveData()
    }
}

