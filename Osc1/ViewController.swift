//
//  ViewController.swift
//  Osc1
//
//  Created by Vinicius Mello on 03/05/15.
//  Copyright (c) 2015 Vinicius Mello. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var blockChannel : AEBlockChannel?
    var oscillatorPosition : Float = 0
    var oscillatorRate : Float = 622.0/44100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        blockChannel = AEBlockChannel(block: {
            (time: UnsafePointer<AudioTimeStamp>,
                frames: UInt32,
                audio: UnsafeMutablePointer<AudioBufferList>) in
            let timeStamp = time.memory
            
            let buffers : UnsafeMutablePointer<AudioBuffer> = withUnsafeMutablePointer(&audio.memory.mBuffers, { (ptr: UnsafeMutablePointer<AudioBuffer>) -> UnsafeMutablePointer<AudioBuffer>  in ptr } )
            
            let data0 = UnsafeMutableBufferPointer<Int16>(start: UnsafeMutablePointer<Int16>(buffers[0].mData), count: Int(frames))
            let data1 = UnsafeMutableBufferPointer<Int16>(start: UnsafeMutablePointer<Int16>(buffers[1].mData), count: Int(frames))
            
            for i in 0..<Int(frames) {
                var x : Float = self.oscillatorPosition
                
                x *= x; x -= 1.0; x *= x;       // x now in the range 0...1
                x *= Float(Int16.max)
                x -= Float(Int16.max) / 2
                
                self.oscillatorPosition += self.oscillatorRate;
                
                if self.oscillatorPosition > 1.0 { self.oscillatorPosition -= 2.0
                }
                
                
                data0[i] = Int16(x)
                //var k = data0[i]
                data1[i] = Int16(x)
                
            }
            
        })
        
        blockChannel!.channelIsMuted = false
        blockChannel!.volume = 1.0
        blockChannel!.audioDescription = AEAudioController.nonInterleaved16BitStereoAudioDescription()
            
        audioController!.addChannels([blockChannel!])
        audioController!.preferredBufferDuration = 0.005
        do {
            try audioController!.start()
        } catch _ {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

