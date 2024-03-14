import AVFoundation
import UIKit
import CoreML
 
var player: AVAudioPlayer?
 
func test_model() {
    print("bro")
    // Fetch the Sound data set.
    if let asset = NSDataAsset(name:"audio"){
           
       let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempSoundFile.caf")

       do {
           try asset.data.write(to: tempFileURL)
       } catch {
           fatalError("Error writing asset data to file: \(error)")
       }

       do {
           let audioFile = try AVAudioFile(forReading: tempFileURL)
           let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false)!
           guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(audioFile.length)) else {return}
           
           try audioFile.read(into: buffer)

           // Assuming non-interleaved stereo or mono, buffer.floatChannelData contains pointers to the audio data
           guard let floatChannelData = buffer.floatChannelData else { return }
           
           let frameLength = Int(buffer.frameLength)
           let channelArray = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

           print(channelArray.count)
           
           let model = try mel_ppg_model()
           print(model)

           let input = MLShapedArray(repeating: Float32(0.0), shape: [1, channelArray.count])
           
           guard let output = try? model.prediction(audio_1: input) else {
               fatalError("Unexpected runtime error.")
           }
           
           for i in 0..<40 {
               let prob : Float = output.var_646ShapedArray[scalarAt: [0, i, 0]]
               print(prob)
           }
           
           // Clean up temporary file
           try FileManager.default.removeItem(at: tempFileURL)
       } catch {
           fatalError("Error processing audio file: \(error)")
       }
    }
 }
