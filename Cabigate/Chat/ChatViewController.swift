//
//  ChatViewController.swift
//  Cabigate
//
//  Created by Nasrullah Khan  on 01/12/2017.
//  Copyright © 2017 Nasrullah Khan . All rights reserved.
//

import UIKit
import XLPagerTabStrip
import JSQMessagesViewController
import SwiftMoment
import RxSwift

class ChatViewController: JSQMessagesViewController {
    
    private var messages: [JSQMessage] = [JSQMessage]()
    var player: AVAudioPlayer?

    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.inputToolbar.contentView.leftBarButtonItem = nil
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
  
        if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
            self.senderId = realmDriver.userId!
            self.senderDisplayName = realmDriver.username
        }
        
        Driver.shared.asObservable().subscribe { (driver) in
            guard let driver = Driver.shared.value else { return }
            if driver.jobDetails != nil {
                //self.inputToolbar.contentView.textView.isUserInteractionEnabled = true
                self.viewDidLayoutSubviews()
                if let realmDriver = DatabaseManager.realm.objects(Driver.self).first {
                        self.senderId = realmDriver.userId!
                        self.senderDisplayName = realmDriver.username
                }
            }
            }.disposed(by: self.disposeBag)
        
        Driver.messages.asObservable().subscribe { (messages) in
            self.messages = Driver.messages.value
            self.finishReceivingMessage()
            
            let chatMessageObject = self.messages.last
         
            print(chatMessageObject?.senderId ?? "pata nhi")
            print(chatMessageObject?.text ?? "pata nhi")

                if self.senderId != chatMessageObject?.senderId && chatMessageObject != nil
                {
//                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
//                    JSQSystemSoundPlayer.shared().playSound(withFilename: "short_sms_tone", fileExtension: "mp3")
                  //  self.playSound()
                    
                }
            
            
            
         
            
        }.disposed(by: self.disposeBag)
    }
    func playSound() {
        guard let url = Bundle.main.url(forResource: "short_sms_tone", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView.backgroundColor = .clear
        self.addBackground()
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        CabigateSocket.socket.emit("sendmessage", ["to":"dispatcher","message":text])
        Driver.messages.value.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text))
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
}

extension ChatViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "CHAT", image: #imageLiteral(resourceName: "chatUnselected"))
    }
}

