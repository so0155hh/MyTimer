//
//  ViewController.swift
//  MyTimer
//
//  Created by 桑原望 on 2020/01/16.
//  Copyright © 2020 MySwift. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    var startTime: TimeInterval? = nil
    var MstartTime: TimeInterval? = nil
    var timer: Timer?
    //24秒ルールの経過時間
    var elapsedTime: Double = 0.0
    //試合時間の経過時間
    var MelapsedTime: Double = 0.0
    //var count = 0
    let settingKey = "timer_value"
    let matchTimerSettingKey = "matchTimeTimer_value"
    let userDefaults = UserDefaults.standard
    //ブザーの音源ファイルを指定
    let buzzerPath = Bundle.main.bundleURL.appendingPathComponent("BuzzerSounding.mp3")
    var buzzerPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = UserDefaults.standard
        settings.register(defaults: [settingKey:24])
        settings.register(defaults: [matchTimerSettingKey:10])
        matchTimeResetBtn.isHidden = true
    }
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var shotClockLabel: UILabel!
    @IBOutlet weak var fourteenLabel: UILabel!
    @IBOutlet weak var matchTimeStartBtn: UIButton!
    @IBOutlet weak var matchTimeResetBtn: UIButton!
    
    @IBAction func settingButtonAction(_ sender: Any) {
        
        performSegue(withIdentifier: "goSetting", sender: nil)
    }
    
    @IBAction func MatchTimeSettingBtn(_ sender: Any) {
        performSegue(withIdentifier: "goMatchTimeSetting", sender: nil)
    }
    @IBAction func startButtonAction(_ sender: Any) {
        //もしタイマーが実行中だったら停止
        if let nowTimer = timer {
            if nowTimer.isValid == true {
                return
            }
        }
            //ボタンをタップした時の時間
        self.startTime = Date.timeIntervalSinceReferenceDate
        self.MstartTime = Date.timeIntervalSinceReferenceDate
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                          target: self,
                                          selector: #selector(self.update),
                                          userInfo: nil,
                                          repeats: true)
    }
    //14秒ルールの適用
    @IBAction func fourteenResetBtn(_ sender: Any) {
        let timerValue = userDefaults.integer(forKey: settingKey)
        //24秒ルール時
        if timerValue == 24 {
            self.startTime = Date.timeIntervalSinceReferenceDate
            elapsedTime = 10.0
        } else if timerValue == 30 {
            self.startTime = Date.timeIntervalSinceReferenceDate
            elapsedTime = 16.0
        }
        }
    //全タイマー停止
    @IBAction func stopBtn(_ sender: Any) {
        if let startTime = self.startTime {
            //経過時間を保存
            self.elapsedTime += Date.timeIntervalSinceReferenceDate - startTime
        }
        if let MstartTime = self.MstartTime {
            
            self.MelapsedTime += Date.timeIntervalSinceReferenceDate - MstartTime
        }
            
       self.timer?.invalidate()
    }
    @IBAction func resetBtn(_ sender: Any) {
        
         let shotCLockTimer = userDefaults.integer(forKey: "timer_value")
               //self.elapsedTime = 0.0
               //shotClockLabel.text = String(shotCLockTimer)
        self.startTime = Date.timeIntervalSinceReferenceDate
        self.elapsedTime = 0.0
       shotClockLabel.text = String(shotCLockTimer) + ".0"
    }
    
    @IBAction func matchTimeResetBtn(_ sender: Any) {
        
        let matchTimer = userDefaults.integer(forKey:"matchTimeTimer_value")
        self.MstartTime = Date.timeIntervalSinceReferenceDate
        self.MelapsedTime = 0.0
        
     //   let matchTimer = userDefaults.integer(forKey:"matchTimeTimer_value")
        countDownLabel.text = String(matchTimer) + ":00.00"
        // self.MstartTime = Date.timeIntervalSinceReferenceDate
           //    self.MelapsedTime = 0.0
        matchTimeResetBtn.isHidden = true
        matchTimeStartBtn.isHidden = false
    }
    
    @objc func update() {
        //試合時間の処理
        let matchTimerValue = userDefaults.integer(forKey: matchTimerSettingKey) * 60

        if let MstartTime = self.MstartTime {
            let Mt: Double = Double(matchTimerValue) - (Date.timeIntervalSinceReferenceDate - MstartTime + self.MelapsedTime)
            let Mmin = Int(Mt / 60)
            let Msec = Int(Mt) % 60
            let Mmsec = Int((Mt - Double(Mmin * 60) - Double(Msec)) * 100.0)
            self.countDownLabel.text = String(format: "%02d:%02d.%02d", Mmin , Msec, Mmsec)
            
            if Mt <= 0.0 {
                do {
                    buzzerPlayer = try AVAudioPlayer(contentsOf: buzzerPath, fileTypeHint: nil)
                    buzzerPlayer.play()
                } catch {
                    print("ブザーでエラーが発生しました")
                }
                self.timer?.invalidate()
                matchTimeStartBtn.isHidden = true
                matchTimeResetBtn.isHidden = false
            }
        }
        
        //24秒ルールの処理
        let timerValue = userDefaults.integer(forKey: settingKey)
        if let startTime = self.startTime {
            let t: Double = Double(timerValue) - (Date.timeIntervalSinceReferenceDate - startTime + self.elapsedTime)
            let min = Int(t / 60)
            let sec = Int(t) % 60
              let msec = Int((t - Double(min * 60) - Double(sec)) * 100.0)
            self.shotClockLabel.text = String(format: "%01d.%02d", sec, msec)
            
            if t <= 0.0 {
                do {
                    buzzerPlayer = try AVAudioPlayer(contentsOf: buzzerPath, fileTypeHint: nil)
                    buzzerPlayer.play()
                } catch {
                    print("ブザーでエラーが発生しました")
                }
                
                //shotClock = 0 になったら、試合時間を保存する
                if let startTime = self.startTime {
                    self.MelapsedTime += Date.timeIntervalSinceReferenceDate - startTime
                }
                self.timer?.invalidate()
                //  matchTimeResetBtn.isHidden = false
                matchTimeStartBtn.isHidden = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let shotCLockTimer = userDefaults.integer(forKey: "timer_value")
        self.elapsedTime = 0.0
        shotClockLabel.text = String(shotCLockTimer) + ".0"
        
        
        let matchTimer = userDefaults.integer(forKey:"matchTimeTimer_value")
        countDownLabel.text = String(matchTimer) + ":00.00"
        // self.MstartTime = Date.timeIntervalSinceReferenceDate
               self.MelapsedTime = 0.0
    }
}

