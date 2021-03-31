import SpriteKit
//import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate /* 追加 */ {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var yunkeru:SKSpriteNode!
    var yunkeruNode:SKNode! //= ["yunkeru", "yunkeru2", "yunkeru3"]
    
    
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let yunkeruCategory: UInt32 = 1 << 4
    
    // スコア用
    var score = 0  // ←追加
    var yunkeruscore = 0
    
    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    let userDefaults:UserDefaults = UserDefaults.standard    // 追加
    var yunkeruscoreLabelNode:SKLabelNode!
    
    
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self // ←追加
        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        
        //        壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        yunkeruNode = SKNode()
        scrollNode.addChild(yunkeruNode)
        
        
        
        //        各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()   // 追加
        setupYunkeru()
        setupYunkeruScoreLabel()
        
    }
    func setupGround() {
        // 地面の画像を読み込む　　定義
        let groundTexture = SKTexture(imageNamed: "ground")
        
        //        なに？
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置（場所）を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false   // ←追加
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    func  setupCloud() {
        //        雲の画像を読み込む
        let cloudTextture = SKTexture(imageNamed: "cloud")
        cloudTextture.filteringMode = .nearest
        
        //        必要な枚数を計算
        let  needCloudNumber = Int(self.frame.size.width / cloudTextture.size().width) + 2
        
        //        スクロールするアクションを作成
        //        左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTextture.size().width, y: 0, duration: 20)
        
        //        元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTextture.size().width, y: 0, duration: 0)
        //        左にスクロールー＞元の位チー＞左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //        スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTextture)
            sprite.zPosition = -100 //一番後ろになるようにする
            //            スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTextture.size().width / 2 + cloudTextture.size().width * CGFloat(i),
                y: self.size.height - cloudTextture.size().height / 2
            )
            //            スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            
            //            スプライトを追加する
            scrollNode.addChild(sprite)
            
            
            
            
        }
        
        
    }
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        //        なに？
        wallTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        
        
        
        
        
        
        
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3
        
        // 隙間位置の上下の振れ幅を鳥のサイズの2.5倍とする
        let random_y_range = birdSize.height * 2.5
        
        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        
        
        
        
        
        
        
        
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥 値が大きいほど前へ
            
            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            under.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
            
            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false    // ←追加
            
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())// ←追加
            under.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false    // ←追加
            
            wall.addChild(upper)
            
            // スコアアップ用のノード --- ここから ---
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            // --- ここまで追加 ---
            
            wall.run(wallAnimation)
            
            //           ノードを追加
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの時間待ちのアクションを作成 duration秒数
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // スプライトを作成。
        bird = SKSpriteNode(texture: birdTextureA)
        //        初期位置をセット
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        // 物理演算を設定　鳥を円として。鳥の大きさの半分の半径として
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // 衝突した時に回転させない　アローローテーション
        bird.physicsBody?.allowsRotation = false    // ←追加
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory    // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | yunkeruCategory    // ←追加
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    //     画面をタップした時に呼ばれる　タッチズビガン
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 { // 追加
            // 鳥の速度をゼロにする　動きを止める
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 { // --- ここから ---
            restart()
        } // --- ここまで追加 ---
    }
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            
            scoreLabelNode.text = "Score:\(score)"    // ←追加
            
            
            // ベストスコア更新か確認する --- ここから ---
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            } // --- ここまで追加---
        }else if(contact.bodyA.categoryBitMask & yunkeruCategory) == yunkeruCategory || (contact.bodyB.categoryBitMask & yunkeruCategory) == yunkeruCategory {
            print("GetYunkeru!")
            yunkeruscore += 1
            yunkeruscoreLabelNode.text = "YunkeruScore:\(yunkeruscore)"
            
            contact.bodyA.node?.removeFromParent()
            //            contact.bodyB.node?.xScale = 1.5
            
            
            
            let mySoundAction: SKAction = SKAction.playSoundFileNamed("kikanai.mp3", waitForCompletion: true)
            // 再生アクション
            self.run(mySoundAction);
            print("SE:played")
            
        }
        
        
        else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    func restart() {
        score = 0
        yunkeruscore = 0
        scoreLabelNode.text = "Score:\(score)"    // ←追加
        //        yunkeruscoreLabelNode.text = "YunkeruScore:\(score)"
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    func setupScoreLabel() {
        score = 0
        
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    func setupYunkeruScoreLabel() {
        yunkeruscore = 0
        yunkeruscoreLabelNode = SKLabelNode()
        yunkeruscoreLabelNode.fontColor = UIColor.black
        yunkeruscoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        yunkeruscoreLabelNode.zPosition = 100 // 一番手前に表示する
        yunkeruscoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        yunkeruscoreLabelNode.text = "Yunkeruscore:\(yunkeruscore)"
        self.addChild(yunkeruscoreLabelNode)
        
    }
    
    
    func setupYunkeru() {
        
        
        let yunkeruTexter = SKTexture(imageNamed: "yunkeru1")
        yunkeruTexter.filteringMode = .linear
        
        
        //        yunkeruTexter.setScale(0.5)
        //
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + yunkeruTexter.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveYunkeru = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
        // 自身を取り除くアクションを作成
        let removeYunkeru = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let yunkeruAnimation = SKAction.sequence([moveYunkeru, removeYunkeru])
        
        
        // Itemを生成するアクションを作成
        let createItemAnimation = SKAction.run({
            
            // 関連のノードを乗せるノードを作成
            let yunkeru = SKNode()
            yunkeru.position = CGPoint(x: self.frame.size.width + yunkeruTexter.size().width / 2, y: 200)
            yunkeru.zPosition = -50.0 // 雲より手前、地面より奥
            yunkeru.xScale = 0.4
            yunkeru.yScale = 0.4
            // 画面のY軸の中央値
            let center_y = self.frame.size.height
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height
            // 下の壁のY軸の下限
            let under_item_lowest_y = UInt32( center_y - yunkeruTexter.size().height / 2 -  random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_item_y = CGFloat(under_item_lowest_y + random_y)
            
            
            // Itemを作成
            let yunkeruobject = SKSpriteNode(texture: yunkeruTexter)
            yunkeruobject.position = CGPoint(x: 90.0, y: under_item_y)
            //            yunkeruobject.xScale = 0.5
            //            yunkeruobject.yScale = 0.5
            
            //    スプライトに物理演算を設定する
            yunkeruobject.physicsBody = SKPhysicsBody(rectangleOf: yunkeruTexter.size())    // ←追加
            yunkeruobject.physicsBody?.categoryBitMask = self.yunkeruCategory    // ←追加
            
            // 衝突の時に動かないように設定する
            yunkeruobject.physicsBody?.isDynamic = false    // ←追加
            
            
            yunkeru.addChild(yunkeruobject)
            
            
            yunkeru.run(yunkeruAnimation)
            
            self.yunkeruNode.addChild(yunkeru)
        })
        
        // 次のItem作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 4)
        
        // Itemを作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        
        yunkeruNode.run(repeatForeverAnimation)
    }
}








//let position = CGFloat(randomYunkeruPosition.nextInt())
//
//yunkeru.position = CGPoint(x: position, y: self.frame.size.height + yunkeru.size.height)
//
//yunkeru.physicsBody = SKPhysicsBody(rectangleOf: yunkeru.size)
//yunkeru.physicsBody?.isDynamic = true
//
//yunkeru.physicsBody?.categoryBitMask = yunkeruCategory
//yunkeru.physicsBody?.contactTestBitMask = photonTorpedocategory
//yunkeru.physicsBody?.collisionBitMask = 0
//
//
//self.addChild(yunkeru)
//
//let animationDuration = 6
//var actionArry = [SKAction]()
//
//actionArry.append(SKAction.move(to: CGPoint(x: position,y: -yunkeru.size.height), duration: TimeInterval(animationDuration)))
//yunkeru.run(SKAction.sequence(actionArry))
