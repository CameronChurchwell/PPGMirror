//
//  ContentView.swift
//  PPGMirror
//
//  Created by Cameron Churchwell on 2/29/24.
//

import SwiftUI

//let buffer = MicrophoneBuffer(frameSize: 1024)

//let ppg = PPG(phonemes: ["aa", "ae", "ah"], num_frames: 6)
let lppg = LivePPG(phonemes: PHONEMES, max_frames: 12)

struct ContentView: View {
    var body: some View {
        VStack {
            lppg.display
            Spacer()
            Text("Press the button and start speaking")
            Button("Start Recording") {
//                do {
//                    try lppg.toggle()
//                } catch {
//                    print("failed to start")
//                }
                test_model()
            }
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
