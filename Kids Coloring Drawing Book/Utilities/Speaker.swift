import Foundation
import AVFoundation

class Speaker {
    
    let synthesizer = AVSpeechSynthesizer()
    
    func speak(messages: String) {
        let utterance = AVSpeechUtterance(string: messages)
        let voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.1
        utterance.preUtteranceDelay = 0.5
        if #available(macCatalyst 14.0, *) {
            synthesizer.usesApplicationAudioSession = false
        } else {
            // Fallback on earlier versions
        }
        synthesizer.speak(utterance)
    }
}
