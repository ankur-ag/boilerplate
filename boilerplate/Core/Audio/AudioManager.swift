//
//  AudioManager.swift
//  boilerplate
//
//  Manages sound effects for the app
//

import AVFoundation
import Foundation

class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            // Use .playback so it plays even if silent switch is ON (requested "loud" cheer)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ [Audio] Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    
    func playCrowdCheer() {
        playSound(named: "crowd_cheer", extension: "mp3")
    }
    
    func playRoastReveal() {
        playSound(named: "roast_reveal", extension: "mp3")
    }
    
    func playSuccessSound() {
        playSound(named: "success", extension: "mp3")
    }
    
    // MARK: - Private Methods
    
    private func playSound(named name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ [Audio] Sound file not found: \(name).\(ext)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("🔊 [Audio] Playing: \(name)")
        } catch {
            print("❌ [Audio] Failed to play sound: \(error)")
        }
    }
    
    func stopAllSounds() {
        audioPlayer?.stop()
    }
}
