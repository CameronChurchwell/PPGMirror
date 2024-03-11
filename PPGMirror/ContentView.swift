//
//  ContentView.swift
//  PPGMirror
//
//  Created by Cameron Churchwell on 2/29/24.
//

import SwiftUI
import AVFoundation

enum MicrophoneBufferError: Error {
    case initialization(message: String)
    case start(message: String)
}

class MicrophoneBuffer {
    var audioEngine: AVAudioEngine
    var audioSession: AVAudioSession
    var buffer : [Float32]
    var frameSize : Int
    var recording = false
    
    func clear() {
        self.buffer = []
    }
    
    func appendBuffer(buffer: AVAudioPCMBuffer) {
        guard let pointer = buffer.floatChannelData else {
            return
        }
        let count = Int(buffer.frameLength)
        
        // Assume audio is single channel
        let channelData = pointer[0]
        let channelArray = Array(UnsafeBufferPointer(start: channelData, count: count))
        self.buffer += channelArray
    }
    
    func start() throws {
        do {
            try self.audioEngine.start()
        } catch {
            
            throw MicrophoneBufferError.start(message: "Failed to start recording")
        }
        self.recording = true
    }
    
    func stop() {
        self.recording = false
        self.audioEngine.stop()
        print(self.buffer.count)
        print(self.buffer.count/self.frameSize)
    }
    
    func toggle() throws {
        if self.recording {
            self.stop()
        } else {
            try self.start()
        }
    }
    
    init(frameSize: Int) {
        self.audioEngine = AVAudioEngine()
        self.audioSession = AVAudioSession.sharedInstance()
        self.buffer = []
        self.frameSize = frameSize
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: UInt32(frameSize), format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.appendBuffer(buffer: buffer)
            }
        } catch {
            //throw MicrophoneBufferError.initialization(message: "Failed to create MicrophoneBuffer!")
            print("Failed to start!")
        }
    }
}

let buffer = MicrophoneBuffer(frameSize: 1024)

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Press the button and start speaking")
            Button("Start Recording") {
                do {
                    try buffer.toggle()
                } catch {
                    print("failed to start")
                }
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
