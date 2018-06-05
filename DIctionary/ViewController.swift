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
        let text = "プロ５年目、１５試合目の登板で初勝利を狙った楽天・古川侑利投手（２２）が、勝ち投手の権利を持って降板した。５回９８球を投げて８三振を奪い、６安打１失点。１点リードの６回には２番手・宋家豪にマウンドを譲った。５月２９日のＤｅＮＡ戦（横浜）以来中６日で、今季２試合目の先発となった古川。初回に先頭の陽岱鋼にいきなり二塁打を浴びて、続く田中俊に四球を与え無死一、二塁のピンチを迎えたが、後続を打ち取って波に乗った。２回以外は毎回走者を背負ったが、失った点は５回に浴びた岡本の適時打による１点のみ。１点差に迫られた５回２死一、三塁ではマギーをこの日最速１４９キロの直球で空振り三振に切って、大きなガッツポーズを見せた。「交流戦、巨人１－４楽天」（５日、東京ドーム）楽天が先発の古川侑利投手（２２）が５回１失点と好投し、プロ初勝利を挙げた。チームは今季の交流戦初白星となった。古川は初回に陽の二塁打と田中俊への四球でピンチを招いたが、岡本、亀井の４、５番から連続で三振を奪ってリズムに乗った。五回には２点リードの五回には、１点を失いなおも２死満塁のピンチで、迎えたマギーを空振り三振にきってとり、窮地を脱した。５回を投げ６安打８奪三振と巨人打線を相手に踏ん張り、救援陣に後を託した。打線は三回に茂木の２ラン、八回の田中の適時打などで４点を挙げた。ウイニングボールを手にカメラマンのフラッシュを浴びた古川。ヒーローインタビューでは「本当に、心の底かうれしかったです。いやあ…本当、長かったですね。やっと勝てて、プロ野球選手になったなという気持ちです」と胸の内を語った。ウイニングボールは、「まずは奧さんに。その後は実家に送りたいと思います」と感謝の思いを込めていた。「交流戦、巨人１－４楽天」（５日、東京ドーム）巨人が今季最多タイ１２残塁の拙攻で、今季３度目の３連敗を喫した。４試合連続の２桁残塁となった。ローテーションの柱となることを期待されている山口俊が先発した。三回に茂木に浴びた２ラン以外は安定した投球を見せていたが、八回に２つの四球を許し、１死一、二塁から１番・田中に一、二塁間を破られる適時打を浴びた。７回１／３を３安打ながら４失点で、降板した。山口俊以上に打線が楽天の投手陣を助けてしまった。初勝利を狙う古川から６本のヒットを打ちながらも得点につながったのは五回の岡本の適時打だけ。合計１２残塁とあと１本が出ないまま、試合が終わってしまった。４番に座って３試合目の岡本は、適時打を含む２安打と３試合連続となるマルチ安打を記録したが、打線としてはつながりを欠いた。ヤクルトが3年ぶりの6連勝をマークし、ソフトバンクと並び交流戦首位に浮上。山田哲、バレンティン、青木に豪快弾が飛び出すなど、15安打12得点と打線が爆発した。ヤクルトは1点を追う2回、1番山田哲が14号3ランを放ち逆転。3回には4番バレンティンが14号ソロを放ち5-2とリードを広げた。4回にも、2番青木に3号3ランが飛び出し8-3。その後も5番雄平、6番西浦がそれぞれ適時二塁打を放ち、4回は打者10人を送り込む猛攻で一気に7点を加えた。先発の石川は、序盤に2本塁打を浴びるも6回を投げ6安打3失点。打線の大量援護にも恵まれ、約2カ月ぶりの白星となる、今季3勝目（2敗）を手にした。ソフトバンクは、投手陣が序盤から崩れ連勝は6でストップ。先発の摂津が3回5失点（自責4）で今季初黒星（1勝）。2番手・岡本も1イニング7失点と崩れ、4回までに12失点を喫した。"
        getCategory(content: text)
    }
    
    func getCategory(content: String) {
        if #available(iOS 11.0, *) {
            let vec = self.tfidf(text: content)
            print(vec)
            do {
                let prediction = try CategoryClassifier2().prediction(message: vec).what_the_category_is
                print(prediction)
            } catch {
                print("error")
            }
        } else {
            print("error")
        }
    }
    
    func tfidf(text: String) -> MLMultiArray {
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"), options: 0)
        var wordList: [String] = []
        var idfDic = [String : Float]()
        var tfDic = [String : Float]()
        var tfidfDic = [String : Float]()

        //--------------------tf-idfを求めてる-----------------
        tagger.string = text
        tagger.enumerateTags(in: NSRange(location: 0, length: text.characters.count), scheme: .tokenType, options: [.omitPunctuation, .omitWhitespace, .omitOther]) { tag, tokenRange, sentenceRange, _ in
            let subString = (text as NSString).substring(with: tokenRange)
            wordList.append(subString as String)
        }

        print(wordList)
        let path = Bundle.main.path(forResource: "dictionary", ofType: "json")
        do {
            let jsonStr = try String(contentsOfFile: path!)
            let json = JSON.parse(jsonStr)

            for word in wordList {
                if json[word] == JSON.null {
                    idfDic[word] = 1
                } else {
                    idfDic[word] = json[word].float! + 1.0
                }
                tfDic[word] = Float(wordList.filter({$0 == word}).count)
            }
            print(idfDic)
            print(tfDic)
            for word in wordList {
                tfidfDic[word] = tfDic[word]! * idfDic[word]!
            }
            print(tfidfDic.count)
//            let sortedDic = tfidfDic.sorted() { $0.1 > $1.1 }
//            for i in 0...4 {
//                print(sortedDic[i])
//            }
            //--------------------ここまで-----------------
            //ベクトル化を考える
            let wordsFile = Bundle.main.path(forResource: "wordlist", ofType: "txt")
            let wordsFileText = try String(contentsOfFile: wordsFile!, encoding: String.Encoding.utf8)
            var wordsData = wordsFileText.components(separatedBy: .newlines)
            let vectorized = try MLMultiArray(shape: [NSNumber(integerLiteral: wordsData.count)], dataType: MLMultiArrayDataType.double)
            for i in 0..<wordsData.count {
                let word = wordsData[i]
                if tfidfDic[word] != nil {
                    vectorized[i] = NSNumber(value: tfidfDic[word]!)
                } else {
                    vectorized[i] = 0
                }
            }

            return vectorized

        } catch {
            print("error")
            return MLMultiArray()
        }
    }
}

