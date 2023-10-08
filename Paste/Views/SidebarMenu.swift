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
            NavigationLink(destination: Text("全部内容")) {
                Label("全部", systemImage: "house")
            }
            // 剪贴类型
            Section(header: Text("剪贴类型")) {
                
                NavigationLink(destination: Text("文本内容")) {
                    Label("文本", systemImage:"doc.plaintext")
                }
                
                NavigationLink(destination: Text("富文本内容")) {
                    Label("富文本", systemImage: "doc.richtext")
                }
                
                NavigationLink(destination: Text("链接内容")) {
                    Label("链接", systemImage: "link")
                }
                
                NavigationLink(destination: Text("图片内容")) {
                    Label("图片", systemImage: "photo")
                }
                
                NavigationLink(destination: Text("文件内容")) {
                    Label("文件", systemImage: "doc")
                }
                
                NavigationLink(destination: Text("多文件内容")) {
                    Label("多文件", systemImage: "doc.on.doc")
                }
            }
            
            // 设置
            Section(header: Text("设置")) {
                NavigationLink(destination: SettingsView()) {
                    Label("设置", systemImage: "gearshape")
                }
                
                NavigationLink(destination: Text("调试页面")) {
                    Label("调试", systemImage: "ladybug")
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
