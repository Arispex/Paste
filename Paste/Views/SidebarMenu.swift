//
//  SidebarMenu.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import SwiftUI

struct SidebarMenu: View {
    
    var body: some View {
        List {
            // 设置
            Section(header: Text("设置")) {
                NavigationLink(destination: GeneralSettingsView()) {
                    Label("通用设置", systemImage: "gearshape")
                }
                
                NavigationLink(destination: ShortcutSettingsView()) {
                    Label("快捷键", systemImage: "keyboard")
                }
            }
            .listStyle(SidebarListStyle())
        }
    }
    
    struct SidebarMenu_Previews: PreviewProvider {
        static var previews: some View {
            SidebarMenu()
        }
    }
}
