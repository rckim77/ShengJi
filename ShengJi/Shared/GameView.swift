//
//  GameView.swift
//  ShengJi
//
//  Created by Ray Kim on 7/24/20.
//  Copyright © 2020 Ray Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

protocol GameViewDelegate: class {
    /// Only used by host
    func gameViewDidTapLeaveButton()
    /// Used by both host and players
    func gameViewDidTapLevelsButton()
    func gameViewDidTapDrawButton()
    func gameViewDealerFinishedExchanging()
    func gameViewUser(_ username: String, didPlay card: String)
    func gameViewUserDidTryToPlayInvalidCard()
}

final class GameView: UIView {
    
    enum GameState: Equatable {
        /// Users are drawing in counter-clockwise order.
        case draw
        /// Once all users have drawn, the dealer gets to exchange with the bottom cards of the draw
        /// deck.
        case dealerExchange
        /// Once the dealer has finished exchanging, the dealer starts by playing a card from their
        /// hand. The first associated value is the username of the player who just played. The second
        /// associated value is the card abbreviation (e.g., "2C"). The third is the next username to
        /// play.
        case play(String, String, String)
        /// Once every player has played a card, players can no longer play cards. We score, display it,
        /// then begin the next turn and go back to the play state. The first associated value is the
        /// username of the player who just played. The second associated value is the card abbreviation.
        case turnEnd(String, String)
    }
    
    private lazy var gameButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIDevice.current.isSmallDevice ? 8 : 12
        return stackView
    }()
    
    private lazy var endGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        button.addRoundedBorder(color: .systemRed)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()
    
    private lazy var levelsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Levels", for: .normal)
        button.addTarget(self, action: #selector(scoreButtonTapped), for: .touchUpInside)
        button.addRoundedBorder(color: .systemBlue)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()
    
    private lazy var levelTrumpLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private lazy var drawDeckRemainingLabel: UILabel = {
        let label = UILabel()
        label.text = "54 remaining"
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var drawDeckLabel: UILabel = {
        let label = UILabel()
        label.text = "🂠"
        label.font = .systemFont(ofSize: 132)
        return label
    }()
    
    private lazy var drawDeckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Draw", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.addRoundedBorder(color: .systemBlue)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(drawDeckButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .bottom, delegate: self)
        return view
    }()
    
    private lazy var leftPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .left, delegate: self)
        return view
    }()
    
    private lazy var topPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .top, delegate: self)
        return view
    }()
    
    private lazy var rightPlayerView: PlayerHandView = {
        let view = PlayerHandView(position: .right, delegate: self)
        return view
    }()
    
    private lazy var dealerExchangeView: DealerExchangeView = {
        let view = DealerExchangeView(delegate: self)
        return view
    }()
    
    private let participantType: ParticipantType
    private let hostUsername: String
    private let username: String
    private let playerTurnOrder: [String]
    private var indexOffset: Int? {
        playerTurnOrder.firstIndex(of: username)
    }
    private var levelTrump: String?
    private var turnStartCard: String? // e.g., "AD" for ace of diamonds
    var leaderTeam: LeaderTeam?
    private var gameState: GameState = .draw {
        didSet {
            playerHandViews.forEach { $0.gameState = gameState }
            
            switch gameState {
            case .play(_, _, _):
                if oldValue == .dealerExchange { // keep this layout for .turnEnd as well
                    leftPlayerView.snp.remakeConstraints { make in
                        make.leading.equalToSuperview().inset(8)
                        make.centerY.equalToSuperview().offset(UIDevice.current.isSmallDevice ? -114 : -64)
                    }
                    
                    rightPlayerView.snp.remakeConstraints { make in
                        make.trailing.equalToSuperview().inset(8)
                        make.centerY.equalToSuperview().offset(UIDevice.current.isSmallDevice ? -114 : -64)
                    }
                }
            case .turnEnd:
                drawDeckRemainingLabel.isHidden = false
                drawDeckRemainingLabel.text = "Winner is..."
                // update dealer, etc.
            default:
                break
            }
        }
    }
    private var playerHandViews: [PlayerHandView] {
        [bottomPlayerView, rightPlayerView, topPlayerView, leftPlayerView]
    }
    private weak var delegate: GameViewDelegate?
    
    // MARK: - AnyCancellables
    
    private var drawCancellable: AnyCancellable?
    
    // MARK: - Init methods
    
    /// For hosts, the hostUsername and username fields are equivalent.
    init(as participantType: ParticipantType, hostUsername: String, username: String, playerTurnOrder: [String], delegate: GameViewDelegate) {
        self.participantType = participantType
        self.hostUsername = hostUsername
        self.username = username
        self.playerTurnOrder = playerTurnOrder
        self.delegate = delegate
        super.init(frame: .zero)
        
        addSubview(gameButtonsStackView)
        gameButtonsStackView.addArrangedSubview(endGameButton)
        gameButtonsStackView.addArrangedSubview(levelsButton)
        addSubview(levelTrumpLabel)
        addSubview(drawDeckLabel)
        addSubview(drawDeckRemainingLabel)
        addSubview(drawDeckButton)
        playerHandViews.forEach { addSubview($0) }
        
        gameButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        levelTrumpLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(12)
            make.trailing.equalToSuperview().inset(16)
        }
        
        drawDeckLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-92)
        }
        
        drawDeckRemainingLabel.snp.makeConstraints { make in
            make.top.equalTo(drawDeckLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(136)
        }
        
        drawDeckButton.snp.makeConstraints { make in
            make.top.equalTo(drawDeckRemainingLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        bottomPlayerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(36)
            make.leading.trailing.equalToSuperview().inset(4)
            make.height.greaterThanOrEqualTo(190)
        }
        
        leftPlayerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        topPlayerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(8)
            make.centerX.equalToSuperview()
        }
        
        rightPlayerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        endGameButton.isHidden = participantType == .player
        setupPlayerPositions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// In the beginning, the host is the one that draws first. Then, once the host draws,
    /// the person to the host's right (counter-clockwise) is up to draw.
    private func setupPlayerPositions() {
        guard let indexOffset = indexOffset else {
            return
        }
        
        bottomPlayerView.configure(username: playerTurnOrder[indexOffset] + " (me)")
        rightPlayerView.configure(username: playerTurnOrder[(indexOffset + 1) % 4])
        topPlayerView.configure(username: playerTurnOrder[(indexOffset + 2) % 4])
        leftPlayerView.configure(username: playerTurnOrder[(indexOffset + 3) % 4])
        
        let initialDrawEvent = DrawEvent(nextPlayerToDraw: hostUsername,
                                         drawnPlayerIndex: nil,
                                         playerHands: [[], [], [], []],
                                         cardsRemaining: Array(repeating: "", count: 54),
                                         drawnCard: nil)
        updateOnDraw(initialDrawEvent)
    }
    
    @objc
    private func leaveButtonTapped() {
        delegate?.gameViewDidTapLeaveButton()
    }
    
    @objc
    private func scoreButtonTapped() {
        delegate?.gameViewDidTapLevelsButton()
    }
    
    @objc
    private func drawDeckButtonTapped() {
        delegate?.gameViewDidTapDrawButton()
    }
    
    func updateOnDraw(_ drawEvent: DrawEvent) {
        let nextUsername = drawEvent.nextPlayerToDraw
        drawDeckButton.isHidden = nextUsername != username || drawEvent.cardsRemaining.count <= 6
        playerHandViews.forEach { $0.hideTurnLabel(nextUsername != $0.username) }
        
        drawDeckRemainingLabel.text = "\(drawEvent.cardsRemaining.count) left"
        
        // update the UI for only the player that just drew
        guard let drawnPlayerIndex = drawEvent.drawnPlayerIndex, drawEvent.playerHands.count == 4 else {
            return
        }

        viewContainingUsername(playerTurnOrder[drawnPlayerIndex])?.updateHandUI(hand: drawEvent.playerHands[drawnPlayerIndex])
        setLevelTrump(drawEvent)
        
        // begin dealer exchange
        if let dealer = leaderTeam?.dealer, drawEvent.cardsRemaining.count == 6 {
            gameState = .dealerExchange
            playerHandViews.forEach { $0.hideTurnLabel(true) }
            if username == dealer {
                displayExchangeableCards(drawEvent.cardsRemaining)
            } else {
                drawDeckRemainingLabel.text = "Waiting for \(dealer) to exchange..."
            }
        }
    }
    
    func updateOnPlay(_ playEvent: PlayEvent) {
        let username = playerTurnOrder[playEvent.playedPlayerIndex]
        
        // first turn, store played card
        if let dealer = leaderTeam?.dealer, gameState == .play("", "", dealer) {
            turnStartCard = playEvent.playedCard
        }
        
        if playEvent.nextPlayerToPlay == leaderTeam?.dealer { // everybody has played a card
            gameState = .turnEnd(username, playEvent.playedCard)
        } else {
           gameState = .play(username, playEvent.playedCard, playEvent.nextPlayerToPlay)
        }
    }
    
    private func displayExchangeableCards(_ cardsRemaining: [String]) {
        addSubview(dealerExchangeView)
        
        dealerExchangeView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(4)
            make.centerX.equalToSuperview()
        }
        
        dealerExchangeView.configure(cardsRemaining)
    }
    
    func hideExchangeView() {
        dealerExchangeView.removeFromSuperview()
    }
    
    /// Dealer has completed exchanging and tapped the Done button. The
    /// dealer is now setup to play their first card.
    func updateForDealerExchanged() {
        guard let dealer = leaderTeam?.dealer else {
            return
        }
        
        drawDeckRemainingLabel.isHidden = true
        drawDeckLabel.isHidden = true
        bottomPlayerView.deselectCards()
        
        gameState = .play("", "", dealer)
    }
    
    private func viewContainingUsername(_ username: String?) -> PlayerHandView? {
        guard let username = username else {
            return nil
        }

        var playerHandView: PlayerHandView?
        playerHandViews.forEach {
            if $0.username == username {
                playerHandView = $0
            }
        }
        return playerHandView
    }
    
    /// When starting the game, the first 2 automatically determines the trump suit and leader.
    private func setLevelTrump(_ drawEvent: DrawEvent) {
        // todo: do not use hardcoded 2 for rounds beyond the first one
        guard let drawnCard = drawEvent.drawnCard,
            let drawnPlayerIndex = drawEvent.drawnPlayerIndex,
            drawnCard.contains("2") && levelTrump == nil else {
            return
        }
        
        levelTrump = drawnCard
        levelTrumpLabel.text = drawnCard.convertedCardAbbreviationToUnicode()
        
        let suitIndex = drawnCard.index(after: drawnCard.startIndex)
        let drawnCardSuit = drawnCard[suitIndex]
        let isRedSuit = drawnCardSuit == "H" || drawnCardSuit == "D"
        levelTrumpLabel.textColor = isRedSuit ? .systemRed : .label
        
        let leaderIndex = (drawnPlayerIndex + 2) % 4
        leaderTeam = LeaderTeam(dealer: playerTurnOrder[drawnPlayerIndex], leader: playerTurnOrder[leaderIndex])
        viewContainingUsername(leaderTeam?.dealer)?.updateAsDealer()
        viewContainingUsername(leaderTeam?.leader)?.updateAsLeader()
        bottomPlayerView.sortHand(levelTrump: drawnCard)
    }
}

extension GameView: DealerExchangeViewDelegate {
    func dealerExchangeViewDidTapExchangeButton() {
        guard let selectedBottomCard = bottomPlayerView.selectedCard,
            let selectedExchangeCard = dealerExchangeView.selectedCardAbbreviation else {
            return
        }
        
        bottomPlayerView.exchange(card: selectedBottomCard, with: selectedExchangeCard)
        dealerExchangeView.exchange(card: selectedExchangeCard, with: selectedBottomCard)
    }
    
    func dealerExchangeViewDidSelectCard(_ cardAbbreviation: String) {
        // fill in
    }
    
    func dealerExchangeViewDidTapDoneButton() {
        if let levelTrump = levelTrump {
            bottomPlayerView.sortHand(levelTrump: levelTrump)
        }
        delegate?.gameViewDealerFinishedExchanging()
    }
}

extension GameView: PlayerHandViewDelegate {
    func playerHandViewDidSelectCard(_ cardAbbreviation: String, position: PlayerHandView.PlayerPosition, hand: [String]) {
        switch gameState {
        case .play(_, _, username): // this is called right before we hit the play endpoint
            if let levelTrump = levelTrump,
                let turnStartCard = turnStartCard,
                cardAbbreviation.isValidForTurn(hand: hand, levelTrump: levelTrump, turnStartCard: turnStartCard) {
                delegate?.gameViewUser(username, didPlay: cardAbbreviation)
            } else if turnStartCard == nil  { // first turn bypasses validation
                turnStartCard = cardAbbreviation
                delegate?.gameViewUser(username, didPlay: cardAbbreviation)
            } else {
                delegate?.gameViewUserDidTryToPlayInvalidCard()
            }
        default:
            break
        }
    }
}
