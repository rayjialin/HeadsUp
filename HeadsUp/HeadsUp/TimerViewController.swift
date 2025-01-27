//
//  TimerViewController.swift
//  HeadsUp
//
//  Created by ruijia lin on 5/4/18.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

import Foundation
import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    var seconds = 60
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        runTimer()
        
    }
    
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            performSegue(withIdentifier: "reviewSegue", sender: self)
        } else {
            seconds -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%01i:%02i", minutes, seconds)
    }
    
}
