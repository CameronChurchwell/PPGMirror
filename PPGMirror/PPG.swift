//
//  PPG.swift
//  PPGMirror
//
//  Created by Steam Train on 3/11/24.
//

import Foundation

import SwiftUI

class PPG: ObservableObject {
    @Published var posteriorgram: Posteriorgram
    var phonemes: [String]
    var num_frames: Int
    
    init(phonemes: [String], num_frames: Int) {
        self.phonemes = phonemes
        self.num_frames = num_frames
        self.posteriorgram = Posteriorgram(width: num_frames, height: phonemes.count)
    }
}

struct PPGView: View {
    @ObservedObject var ppg: PPG
    
    init(ppg: PPG) {
        self._ppg = ObservedObject(wrappedValue: ppg)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    let vertical_size: CGFloat = geometry.size.height / CGFloat(ppg.phonemes.count)
                    let horizontal_size: CGFloat = vertical_size
                    ForEach(0..<ppg.phonemes.count, id: \.self) { phone_index in
                        ZStack {
                            CellView(color: .blue, width: horizontal_size, height: vertical_size)
                                .padding(EdgeInsets())
                            Text(ppg.phonemes[phone_index])
                                .font(.system(size: 12))
                        }.padding(EdgeInsets())
                    }.padding(EdgeInsets())
                }
                .offset(x: 0, y:0)
            }
            ppg.posteriorgram.display
                .zIndex(-1.0)
        }
    }
    
    func shift_left() {
        self.ppg.posteriorgram.display.shift_left()
    }
}

let frame_size = 1024

class LivePPG {
    var animating: Bool = false
    var ppg: PPG
    var display: PPGView
    var mic_buffer: MicrophoneBuffer? = nil
    
    init(phonemes: [String], max_frames: Int) {
        self.ppg = PPG(phonemes: phonemes, num_frames: max_frames)
        self.display = PPGView(ppg: self.ppg)
        self.mic_buffer = MicrophoneBuffer(frameSize: frame_size, callback: self.callback)
    }
    
    func callback(buffer: MicrophoneBuffer) {
        let buf = self.mic_buffer!.buffer
        print(buf.count)
        self.display.shift_left()
    }
    
    func toggle() {
        do {
            try self.mic_buffer!.toggle()
            self.animating = !self.animating
        } catch {
            print("failed to toggle LivePPG")
        }
    }
}
