//
//  FirstViewController.swift
//  HarkTest
//
//  Created by Jenna Sampson on 7/20/15.
//  Copyright (c) 2015 Jenna Sampson. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController {
    
    var recorder : AVAudioRecorder!
    var player : AVAudioPlayer!
    var meterTimer:NSTimer!
    var soundFileURL:NSURL?
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var imageBucket: UIImageView!
    
    
    @IBAction func stopButtonPressed(sender: AnyObject) {
        
        imageBucket.image = UIImage(named: "cloud3.jpg")
        
        println("stop")
        
        recorder?.stop()
        player?.stop()
        
        recordButton.setTitle("Record", forState:.Normal)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setActive(false, error: &error) {
            println("could not make session inactive")
            if let e = error {
                println(e.localizedDescription)
                return
            }
        }
        stopButton.enabled = false
        recordButton.enabled = true
        //recorder = nil
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
    
        imageBucket.image = UIImage(named: "recordimagecopy.png")
        
        if player != nil && player.playing {
            player.stop()
        }
        
        if recorder == nil {
            println("recording. recorder nil")
            recordButton.setTitle("Pause", forState:.Normal)
            stopButton.enabled = true
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.recording {
            println("pausing")
            recorder.pause()
            recordButton.setTitle("Continue", forState:.Normal)
            
        } else {
            println("recording")
            recordButton.setTitle("Pause", forState:.Normal)
            stopButton.enabled = true
            //            recorder.record()
            recordWithPermission(false)
        }
    }

    
    
    
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func setupRecorder() {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        
        var recordSettings:[NSObject: AnyObject] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                                    } else {
                    println("Permission to record not granted")
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: AVAudioRecorderDelegate
extension FirstViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            println("finished recording \(flag)")
            stopButton.enabled = false
            recordButton.setTitle("Record", forState:.Normal)
            
            // iOS8 and later
            var alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
                println("keep was tapped")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
                println("delete was tapped")
                self.recorder.deleteRecording()
            }))
            self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
}

// MARK: AVAudioPlayerDelegate
extension FirstViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished playing \(flag)")
        recordButton.enabled = true
        stopButton.enabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
}

