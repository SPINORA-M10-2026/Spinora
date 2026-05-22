//
//  ReelGameScene.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SpriteKit

final class ReelGameScene: SKScene {

    private var reelColumns: [[String]] = [
        ["water", "fire", "fire"],
        ["fire", "water", "earth"],
        ["earth", "earth", "water"]
    ]

    private var reelRolledThisTurn: [Bool] = [false, false, false]

    var onReelTap: ((Int) -> Void)?

    var showTapToPlay: Bool = true {
        didSet {
            if !showTapToPlay {
                hideTapToPlay()
            }
        }
    }

    private var tapLabel: SKLabelNode?

    private var machineTransparentNode = SKSpriteNode()
    private var machineBaseNode = SKSpriteNode()

    private var topSymbols: [SKSpriteNode] = []
    private var centerSymbols: [SKSpriteNode] = []
    private var bottomSymbols: [SKSpriteNode] = []

    private var usedSegmentOverlayNodes: [SKShapeNode] = []

    private var touchNodes: [SKShapeNode] = []

    // MARK: - Slot Machine Refresh State

    private var hasInitializedReelState = false
    private var isRandomizingBeforeNewTurn = false
    private var lastFinalizedColumns: [[String]] = []

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        anchorPoint = .zero
        scaleMode = .resizeFill

        buildScene()

        updateScene(
            reelColumns: reelColumns,
            reelRolledThisTurn: reelRolledThisTurn,
            animatedChangedIndex: nil
        )
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0 else {
            return
        }

        buildScene()

        updateScene(
            reelColumns: reelColumns,
            reelRolledThisTurn: reelRolledThisTurn,
            animatedChangedIndex: nil
        )
    }

    func updateScene(
        reelColumns: [[String]],
        reelRolledThisTurn: [Bool],
        animatedChangedIndex: Int?
    ) {
        let previousRolledThisTurn = self.reelRolledThisTurn
        let normalizedColumns = normalizeColumns(reelColumns)

        self.reelColumns = normalizedColumns
        self.reelRolledThisTurn = reelRolledThisTurn

        guard topSymbols.count == 3,
              centerSymbols.count == 3,
              bottomSymbols.count == 3,
              usedSegmentOverlayNodes.count == 3,
              touchNodes.count == 3 else {
            return
        }

        let shouldRandomizeBeforeNewTurn = shouldAnimateBeforeNewPlayerTurn(
            previousRolledThisTurn: previousRolledThisTurn,
            newRolledThisTurn: reelRolledThisTurn,
            animatedChangedIndex: animatedChangedIndex
        )

        if shouldRandomizeBeforeNewTurn {
            hideAllUsedSegmentOverlays()
            animateRandomizeAllReelsBeforeNewTurn(finalColumns: normalizedColumns)
            return
        }

        for index in 0..<3 {
            guard index < self.reelColumns.count,
                  self.reelColumns[index].count >= 3 else {
                continue
            }

            let symbols = self.reelColumns[index]

            if animatedChangedIndex == index {
                animateReelStop(
                    index: index,
                    finalTop: symbols[0],
                    finalCenter: symbols[1],
                    finalBottom: symbols[2]
                )
            } else if !isRandomizingBeforeNewTurn {
                setSymbolTexture(topSymbols[index], symbol: symbols[0])
                setSymbolTexture(centerSymbols[index], symbol: symbols[1])
                setSymbolTexture(bottomSymbols[index], symbol: symbols[2])
            }

            topSymbols[index].alpha = 1.0
            centerSymbols[index].alpha = 1.0
            bottomSymbols[index].alpha = 1.0

            let isUsed = isReelUsed(index)
            usedSegmentOverlayNodes[index].isHidden = !isUsed
        }

        hasInitializedReelState = true
    }

    func hideTapToPlay() {
        guard let label = tapLabel else {
            return
        }

        tapLabel = nil

        label.run(.sequence([
            .fadeOut(withDuration: 0.25),
            .removeFromParent()
        ]))
    }

    private func buildScene() {
        removeAllChildren()

        tapLabel = nil

        topSymbols.removeAll()
        centerSymbols.removeAll()
        bottomSymbols.removeAll()
        usedSegmentOverlayNodes.removeAll()
        touchNodes.removeAll()

        let centerX = size.width / 2
        let centerY = size.height / 2

        // MARK: - Machine Assets

        let machineWidth: CGFloat = 830
        let machineHeight: CGFloat = 1740
        let machinePosition = CGPoint(x: centerX, y: centerY + 570)

        machineTransparentNode = SKSpriteNode(imageNamed: "background_jackpot_element_transparent")
        machineTransparentNode.size = CGSize(width: machineWidth, height: machineHeight)
        machineTransparentNode.position = machinePosition
        machineTransparentNode.zPosition = 1
        addChild(machineTransparentNode)

        machineBaseNode = SKSpriteNode(imageNamed: "background_jackpot_list")
        machineBaseNode.size = CGSize(width: machineWidth, height: machineHeight)
        machineBaseNode.position = machinePosition
        machineBaseNode.zPosition = 10
        addChild(machineBaseNode)

        // MARK: - Reel Layout Values

        let reelXPositions: [CGFloat] = [
            centerX - 214,
            centerX,
            centerX + 214
        ]

        let iconXOffset: CGFloat = 0
        let iconYOffset: CGFloat = -2

        let topYOffset: CGFloat = 103
        let centerYOffset: CGFloat = 2
        let bottomYOffset: CGFloat = -100

        let topIconSize = CGSize(width: 68, height: 68)
        let centerIconSize = CGSize(width: 104, height: 104)
        let bottomIconSize = CGSize(width: 68, height: 68)

        let touchWidth: CGFloat = 190
        let touchHeight: CGFloat = 330

        // MARK: - Used Segment Overlay Adjustment Values
        // Adjust these later if the used overlay is too big/small or misaligned.

        let usedOverlayWidth: CGFloat = 199
        let usedOverlayHeight: CGFloat = 330
        let usedOverlayCornerRadius: CGFloat = 18
        let usedOverlayXOffset: CGFloat = 0
        let usedOverlayYOffset: CGFloat = 0
        let usedOverlayOpacity: CGFloat = 0.42
        let usedOverlayBorderWidth: CGFloat = 0

        // MARK: - Icon Placement

        for index in 0..<3 {
            let x = reelXPositions[index] + iconXOffset
            let y = centerY + iconYOffset

            let topSymbol = SKSpriteNode(imageNamed: "icon_element_water")
            topSymbol.size = topIconSize
            topSymbol.position = CGPoint(x: x, y: y + topYOffset)
            topSymbol.name = "reel_\(index)"
            topSymbol.zPosition = 30
            addChild(topSymbol)
            topSymbols.append(topSymbol)

            let centerSymbol = SKSpriteNode(imageNamed: "icon_element_fire")
            centerSymbol.size = centerIconSize
            centerSymbol.position = CGPoint(x: x, y: y + centerYOffset)
            centerSymbol.name = "reel_\(index)"
            centerSymbol.zPosition = 30
            addChild(centerSymbol)
            centerSymbols.append(centerSymbol)

            let bottomSymbol = SKSpriteNode(imageNamed: "icon_element_earth")
            bottomSymbol.size = bottomIconSize
            bottomSymbol.position = CGPoint(x: x, y: y + bottomYOffset)
            bottomSymbol.name = "reel_\(index)"
            bottomSymbol.zPosition = 30
            addChild(bottomSymbol)
            bottomSymbols.append(bottomSymbol)
        }

        // MARK: - Used Segment Overlay
        // This appears only after a reel section has been rolled.
        // No text label is used.

        for index in 0..<3 {
            let overlayNode = SKShapeNode(
                rectOf: CGSize(
                    width: usedOverlayWidth,
                    height: usedOverlayHeight
                ),
                cornerRadius: usedOverlayCornerRadius
            )

            overlayNode.fillColor = UIColor.black.withAlphaComponent(usedOverlayOpacity)
            overlayNode.lineWidth = usedOverlayBorderWidth
            overlayNode.position = CGPoint(
                x: reelXPositions[index] + usedOverlayXOffset,
                y: centerY + usedOverlayYOffset
            )
            overlayNode.zPosition = 5
            overlayNode.isHidden = true

            addChild(overlayNode)
            usedSegmentOverlayNodes.append(overlayNode)
        }

        // MARK: - Tap Label

        if showTapToPlay {
            let label = makeLabel(text: "TAP TO PLAY!", fontSize: 40)
            label.position = CGPoint(x: centerX, y: centerY)
            label.zPosition = 40
            label.alpha = 0.88
            addChild(label)
            tapLabel = label
        }

        // MARK: - Touch Areas

        for index in 0..<3 {
            let touchNode = SKShapeNode(
                rectOf: CGSize(width: touchWidth, height: touchHeight),
                cornerRadius: 16
            )
            touchNode.fillColor = .clear
            touchNode.strokeColor = .clear
            touchNode.lineWidth = 0
            touchNode.position = CGPoint(x: reelXPositions[index], y: centerY)
            touchNode.name = "reel_\(index)"
            touchNode.zPosition = 60
            addChild(touchNode)
            touchNodes.append(touchNode)
        }
    }

    // MARK: - Slot Machine Randomize Before New Player Turn

    private func shouldAnimateBeforeNewPlayerTurn(
        previousRolledThisTurn: [Bool],
        newRolledThisTurn: [Bool],
        animatedChangedIndex: Int?
    ) -> Bool {
        guard hasInitializedReelState else {
            hasInitializedReelState = true
            lastFinalizedColumns = reelColumns
            return false
        }

        guard animatedChangedIndex == nil else {
            return false
        }

        let newTurnAllSegmentsAvailable = newRolledThisTurn.allSatisfy { $0 == false }
        let reelResultChanged = lastFinalizedColumns != reelColumns

        if newTurnAllSegmentsAvailable && reelResultChanged {
            lastFinalizedColumns = reelColumns
            return true
        }

        lastFinalizedColumns = reelColumns
        return false
    }

    private func animateRandomizeAllReelsBeforeNewTurn(finalColumns: [[String]]) {
        guard topSymbols.count == 3,
              centerSymbols.count == 3,
              bottomSymbols.count == 3 else {
            return
        }

        isRandomizingBeforeNewTurn = true

        for index in 0..<3 {
            guard index < finalColumns.count,
                  finalColumns[index].count >= 3 else {
                continue
            }

            animateRandomizeSingleReelBeforeNewTurn(
                index: index,
                finalTop: finalColumns[index][0],
                finalCenter: finalColumns[index][1],
                finalBottom: finalColumns[index][2],
                delay: Double(index) * 0.12
            )
        }

        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                self?.isRandomizingBeforeNewTurn = false
            }
        ]))
    }

    private func animateRandomizeSingleReelBeforeNewTurn(
        index: Int,
        finalTop: String,
        finalCenter: String,
        finalBottom: String,
        delay: TimeInterval
    ) {
        guard index >= 0,
              index < topSymbols.count,
              index < centerSymbols.count,
              index < bottomSymbols.count else {
            return
        }

        let possibleSymbols = ["fire", "water", "earth"]

        let top = topSymbols[index]
        let center = centerSymbols[index]
        let bottom = bottomSymbols[index]

        let originalTopPosition = top.position
        let originalCenterPosition = center.position
        let originalBottomPosition = bottom.position

        let tick = SKAction.run {
            let randomTop = possibleSymbols.randomElement() ?? "water"
            let randomCenter = possibleSymbols.randomElement() ?? "fire"
            let randomBottom = possibleSymbols.randomElement() ?? "earth"

            self.setSymbolTexture(top, symbol: randomTop)
            self.setSymbolTexture(center, symbol: randomCenter)
            self.setSymbolTexture(bottom, symbol: randomBottom)

            top.position = CGPoint(x: originalTopPosition.x, y: originalTopPosition.y + 12)
            center.position = CGPoint(x: originalCenterPosition.x, y: originalCenterPosition.y + 12)
            bottom.position = CGPoint(x: originalBottomPosition.x, y: originalBottomPosition.y + 12)

            top.run(.move(to: originalTopPosition, duration: 0.045))
            center.run(.move(to: originalCenterPosition, duration: 0.045))
            bottom.run(.move(to: originalBottomPosition, duration: 0.045))
        }

        let cycle = SKAction.sequence([
            tick,
            .wait(forDuration: 0.055)
        ])

        let spin = SKAction.repeat(cycle, count: 12)

        let stop = SKAction.run {
            top.removeAllActions()
            center.removeAllActions()
            bottom.removeAllActions()

            top.position = originalTopPosition
            center.position = originalCenterPosition
            bottom.position = originalBottomPosition

            self.setSymbolTexture(top, symbol: finalTop)
            self.setSymbolTexture(center, symbol: finalCenter)
            self.setSymbolTexture(bottom, symbol: finalBottom)

            center.run(.sequence([
                .scale(to: 1.14, duration: 0.08),
                .scale(to: 1.0, duration: 0.10)
            ]))
        }

        run(.sequence([
            .wait(forDuration: delay),
            spin,
            stop
        ]))
    }

    private func hideAllUsedSegmentOverlays() {
        for overlayNode in usedSegmentOverlayNodes {
            overlayNode.isHidden = true
        }
    }

    private func animateReelStop(
        index: Int,
        finalTop: String,
        finalCenter: String,
        finalBottom: String
    ) {
        guard index >= 0,
              index < topSymbols.count,
              index < centerSymbols.count,
              index < bottomSymbols.count,
              index < touchNodes.count else {
            return
        }

        let possibleSymbols = ["fire", "water", "earth"]

        let top = topSymbols[index]
        let center = centerSymbols[index]
        let bottom = bottomSymbols[index]
        let touchNode = touchNodes[index]

        let tick = SKAction.run {
            let randomTop = possibleSymbols.randomElement() ?? "water"
            let randomCenter = possibleSymbols.randomElement() ?? "fire"
            let randomBottom = possibleSymbols.randomElement() ?? "earth"

            self.setSymbolTexture(top, symbol: randomTop)
            self.setSymbolTexture(center, symbol: randomCenter)
            self.setSymbolTexture(bottom, symbol: randomBottom)
        }

        let cycle = SKAction.sequence([
            tick,
            .wait(forDuration: 0.05)
        ])

        let spin = SKAction.repeat(cycle, count: 10)

        let stop = SKAction.run {
            self.setSymbolTexture(top, symbol: finalTop)
            self.setSymbolTexture(center, symbol: finalCenter)
            self.setSymbolTexture(bottom, symbol: finalBottom)

            center.run(.sequence([
                .scale(to: 1.12, duration: 0.08),
                .scale(to: 1.0, duration: 0.10)
            ]))

            touchNode.run(.sequence([
                .scale(to: 1.03, duration: 0.08),
                .scale(to: 1.0, duration: 0.10)
            ]))
        }

        run(.sequence([
            spin,
            stop
        ]))
    }

    // MARK: - Symbol Mapping

    private func normalizeColumns(_ columns: [[String]]) -> [[String]] {
        columns.map { column in
            column.map { normalizeSymbol($0) }
        }
    }

    private func normalizeSymbol(_ symbol: String) -> String {
        switch symbol {
        case "fire", "🔥":
            return "fire"

        case "water", "💧":
            return "water"

        case "earth", "🪨":
            return "earth"

        default:
            return "fire"
        }
    }

    private func setSymbolTexture(_ node: SKSpriteNode, symbol: String) {
        node.texture = SKTexture(imageNamed: assetName(for: symbol))
    }

    private func assetName(for symbol: String) -> String {
        switch normalizeSymbol(symbol) {
        case "fire":
            return "icon_element_fire"

        case "water":
            return "icon_element_water"

        case "earth":
            return "icon_element_earth"

        default:
            return "icon_element_fire"
        }
    }

    private func makeLabel(text: String, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = fontSize
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }

    private func isReelUsed(_ index: Int) -> Bool {
        guard index >= 0 && index < reelRolledThisTurn.count else {
            return true
        }

        return reelRolledThisTurn[index]
    }

    private func reelIndex(from nodeName: String) -> Int? {
        guard nodeName.starts(with: "reel_") else {
            return nil
        }

        let indexText = nodeName.replacingOccurrences(of: "reel_", with: "")
        return Int(indexText)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isRandomizingBeforeNewTurn else {
            return
        }

        guard let touch = touches.first else {
            return
        }

        let point = touch.location(in: self)
        let touchedNodes = nodes(at: point)

        for node in touchedNodes {
            guard let name = node.name,
                  let index = reelIndex(from: name),
                  !isReelUsed(index) else {
                continue
            }

            onReelTap?(index)
            return
        }
    }
}
