//
//  QuickTranslateApp.swift
//  QuickTranslate
//
//  Created by Никита Евдокимов on 7.04.25.
//

import SwiftUI

@main
struct QuickTranslateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Set app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("QuickTranslate version: \(version)")
        }
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var window: NSWindow?
    private var contentView: NSHostingView<ContentView>?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        createWindow()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        window?.close()
        window = nil
        contentView = nil
        statusItem = nil
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Create a custom image with SF Symbol
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "QuickTranslate")
            image?.withSymbolConfiguration(config)
            button.image = image
            button.imagePosition = .imageLeft
            button.target = self
            button.action = #selector(handleClick(_:))
        }
    }
    
    private func createWindow() {
        let contentView = NSHostingView(rootView: ContentView())
        self.contentView = contentView
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        // Configure window appearance
        window?.title = "QuickTranslate v1.1"
        window?.center()
        window?.contentView = contentView
        window?.isReleasedWhenClosed = false
        window?.orderOut(nil) // Hide window initially
        
        // Make window transparent and rounded
        window?.titlebarAppearsTransparent = false
        window?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        window?.isOpaque = true
        
        // Add rounded corners
        if let contentView = window?.contentView {
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 12
            contentView.layer?.masksToBounds = true
        }
    }
    
    @objc func handleClick(_ sender: Any?) {
        showWindow()
    }
    
    private func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}


