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
        //初期値を登録
        let settings = UserDefaults.standard
        settings.register(defaults: [settingKey:24])
        settings.register(defaults: [matchTimerSettingKey:10])
        matchTimeResetBtn.isHidden = true
        stopBtn.isHidden = true
        shotClockResetBtn.isHidden = true
        fourteenResetBtn.isHidden = true
    }
    @IBOutlet weak var matchTimerLabel: UILabel!
    @IBOutlet weak var shotClockLabel: UILabel!
    @IBOutlet weak var matchTimeStartBtn: UIButton!
    @IBOutlet weak var matchTimeResetBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var shotClockResetBtn: UIButton!
    @IBOutlet weak var fourteenResetBtn: UIButton!
    
    @IBAction func shotClockSetting(_ sender: Any) {
    
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
        matchTimeStartBtn.isHidden = true
        stopBtn.isHidden = false
        shotClockResetBtn.isHidden = false
        fourteenResetBtn.isHidden = false
    }
    //14秒ルールの適用
    @IBAction func fourteenResetBtn(_ sender: Any) {
        let timerValue = userDefaults.integer(forKey: settingKey)
        //24秒ルール時
        if timerValue == 24 {
            self.startTime = Date.timeIntervalSinceReferenceDate
            elapsedTime = 10.0
            shotClockLabel.text = "14"
            //30秒ルール時
        } else if timerValue == 30 {
            self.startTime = Date.timeIntervalSinceReferenceDate
            elapsedTime = 16.0
            shotClockLabel.text = "14"
        }
        matchTimeStartBtn.isHidden = false
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
        matchTimeStartBtn.isHidden = false
        stopBtn.isHidden = true
    }
    @IBAction func resetBtn(_ sender: Any) {
        //shotClockのリセット
         let shotCLockTimer = userDefaults.integer(forKey: "timer_value")
        self.startTime = Date.timeIntervalSinceReferenceDate
        self.elapsedTime = 0.0
       shotClockLabel.text = String(shotCLockTimer)
        matchTimeStartBtn.isHidden = false
        
    }
    @IBAction func matchTimeResetBtn(_ sender: Any) {
        //試合時間のリセット
        let matchTimer = userDefaults.integer(forKey:"matchTimeTimer_value")
        self.MstartTime = Date.timeIntervalSinceReferenceDate
        let shotCLockTimer = userDefaults.integer(forKey: "timer_value")
        self.MelapsedTime = 0.0
        shotClockLabel.text = String(shotCLockTimer)
        
        matchTimerLabel.text = String(matchTimer) + ":00"
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
            let Mmsec = Int((Mt - Double(Mmin * 60) - Double(Msec)) * 10.0)
            if Mt < 10.0 {
            self.matchTimerLabel.text = String(format: "%01d.%01d" , Msec, Mmsec)
            } else  {
                self.matchTimerLabel.text = String(format: "%02d:%02d", Mmin , Msec)
            }
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
                stopBtn.isHidden = true
                shotClockResetBtn.isHidden = true
                fourteenResetBtn.isHidden = true
                
                if Mt < 0 {
                    self.matchTimerLabel.text = "0.00"
                }
            }
        }
        //24秒ルールの処理
        let timerValue = userDefaults.integer(forKey: settingKey)
        if let startTime = self.startTime {
            let t: Double = Double(timerValue) - (Date.timeIntervalSinceReferenceDate - startTime + self.elapsedTime)
            let min = Int(t / 60)
            let sec = Int(t) % 60
              let msec = Int((t - Double(min * 60) - Double(sec)) * 10.0)
            if t < 10.0 {
                self.shotClockLabel.text = String(format: "%01d.%01d", sec, msec)
            } else {
                self.shotClockLabel.text = String(format: "%02d" , sec)
            }
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
                
                if t < 0 {
                    self.shotClockLabel.text = "0.00"
                }
                matchTimeStartBtn.isHidden = true
                stopBtn.isHidden = true
            }
        }
    }
         override func viewDidAppear(_ animated: Bool) {
               //PickerViewで選択された時間を表示する
               let shotCLockTimer = userDefaults.integer(forKey: "timer_value")
               self.elapsedTime = 0.0
               shotClockLabel.text = String(shotCLockTimer)
               
               let matchTimer = userDefaults.integer(forKey:"matchTimeTimer_value")
               matchTimerLabel.text = String(matchTimer) + ":00"
                      self.MelapsedTime = 0.0
        }
    //saveボタンが押されたら、表示を更新する
    @IBAction func backToTpp(segue: UIStoryboardSegue) {
         let shotCLockTimer = userDefaults.integer(forKey: "timer_value")
                     self.elapsedTime = 0.0
                  shotClockLabel.text = String(shotCLockTimer)
    }
    @IBAction func returnGameTimer(segue: UIStoryboardSegue) {
         let matchTimer = userDefaults.integer(forKey:"matchTimeTimer_value")
               matchTimerLabel.text = String(matchTimer) + ":00"
        self.MelapsedTime = 0.0
    }
}

