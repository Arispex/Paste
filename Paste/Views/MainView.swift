//
//  MainView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            SidebarMenu()
            
            // 这里将会是剪贴板内容的显示区域
            Text("选择一个类型来显示内容")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
