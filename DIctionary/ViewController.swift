//
//  ViewController.swift
//  DIctionary
//
//  Created by 横田　涼介 on 2018/05/27.
//  Copyright © 2018年 amy. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreML

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let text = "エンゼルスの大谷翔平投手（２３）は２６日（日本時間２７日）、敵地ニューヨークでのヤンキース戦に「５番・ＤＨ」でスタメン出場。２三振するなど４打数無安打１四球で、メジャーで初めて２試合連続無安打に終わり、打率は・２９７となり３割を切った。チームは１１―４で快勝した。２７日（同２８日）は打者としてヤ軍の田中将大投手（２９）と初対決する予定。試合後、大谷は「先制点は取られましたが、なんとか逆転して後半もいい流れで追加点を取りながら勝てたので。すごいいいゲームだったと思います」とチームの勝利に納得した表情。自身は前日２５日（同２６日）同様に敵地ファンに大ブーイングで迎えられ、初回２死三塁からの第１打席は空振り三振。３回１死満塁からの第２打席は、３ボール１ストライクから押し出し四球を選び、３試合ぶりの打点を挙げたが、５回無死からの第３打席は、２ストライクから高めの直球に空振り三振。６回無死一、三塁からの第４打席は遊ゴロ併殺打、８回１死からの第５打席も遊ゴロに倒れた。いずれも外角中心の配球で、無安打に抑えられ「昨日から正面の当たりが多いですが、そんなに悪くはないかなとは思っています。ゲッツーに関しては外野フライの方がいい場面なので。それの方が良かったけど、まあ１点入ったという結果に関しては良かったかなと思っています」と振り返った。また、相手の守備シフトで打ち取られた打球については「抜けることもありますし。逆にいい打球が正面にいっているということは、自分の打撃をしっかり、打席の中でいいスイングができているのかなと思っている。目先の１安打も大事だと思うんですけど、継続して取り組むところもすごい大事じゃないかなと思っています」と強調。次戦に向けて「自分が思っている以上に、（相手バッテリーが）慎重に慎重にという配球になっているのかなとは思うので。そこも踏まえながら、明日もう１回組み立てていきたいなと思います」と話した。"
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: 0)
        var wordList: [String] = []
        var idfDic = [String : Float]()
        var tfDic = [String : Float]()
        var tfidfDic = [String : Float]()
        
        tagger.string = text
        tagger.enumerateTags(in: NSRange(location: 0, length: text.characters.count), scheme: .tokenType, options: [.omitPunctuation, .omitWhitespace, .omitOther]) { tag, tokenRange, sentenceRange, _ in
                
            let subString = (text as NSString).substring(with: tokenRange)
            wordList.append(subString as String)
        }
        
    //        print(wordList)
        let path = Bundle.main.path(forResource: "dictionary", ofType: "json")
        do {
            let jsonStr = try String(contentsOfFile: path!)
            let json = JSON.parse(jsonStr)
            
            for word in wordList {
                if json[word] == nil {
                    idfDic[word] = 0
                } else {
                    idfDic[word] = json[word].float
                }
                tfDic[word] = Float(wordList.filter({$0 == word}).count) / Float(wordList.count)
            }
            print(idfDic.count)
            print(tfDic.count)
            for word in wordList {
                tfidfDic[word] = tfDic[word]! * idfDic[word]!
            }
            print(tfidfDic.count)
            let sortedDic = tfidfDic.sorted() { $0.1 > $1.1 }
            for i in 0...4 {
                print(sortedDic[i])
            }
        } catch {
            print("error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

