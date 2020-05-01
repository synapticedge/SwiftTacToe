import SwiftUI
import AudioToolbox

let gameStateStrings = ["X's Turn", "O's Turn", "O Wins!", "Draw", "X Wins!"]

enum GameState : Int {
   
   case xTurn = -3;
   case oTurn = -2;
   case draw = 0;
   case xWins = 1;
   case oWins = -1
   
   var text : String {
      return gameStateStrings[self.rawValue + 3]
   }
}

enum SpaceStatus : String { case x = "X" ; case o = "O" ; case empty = " "}

struct TicTacToe{
   
   public var scores : (Int,Int,Int) = (0,0,0)
   
   public var gameState : GameState = GameState.xTurn {
      
      didSet{
         switch gameState{
         case .xWins: scores.0 += 1 ; AudioServicesPlaySystemSound(3)
         case .oWins: scores.1 += 1 ;  AudioServicesPlaySystemSound(1)
         case .draw: scores.2 += 1 ;  AudioServicesPlaySystemSound(4)
         default: assert(true)
         }
      }
   }
   public var board : [SpaceStatus] = Array(repeating: SpaceStatus.empty, count: 9){
      
      didSet{
         gameState = self.checkWinner(board)
         if gameState == .oTurn {
            self.bestMove()
         }
      }
   }
   private func checkWinner(_ board: [SpaceStatus]) -> GameState {
      for combo in [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]{
         
         if Set([board[combo[0]],board[combo[1]], board[combo[2]]]).count == 1{
            if board[combo[0]] == .x {return .xWins}
            if board[combo[0]] == .o {return .oWins}
         }
      }
      
      if (board.indices.filter {board[$0] == .empty}).count == 0 { return .draw } //no winner and no spaces
      
      if self.gameState == .xTurn {return .oTurn} else {return .xTurn} // swap current turn
   }
   mutating func bestMove(){
      
      self.board[findBestMove(self.board)] = .o
   }
   
   func miniMax(_ board: [SpaceStatus], depth: Int, isO: Bool) -> Int {
      
      let result = self.checkWinner(board).rawValue
      
      if result > -2 {
         return (result * 10) + (isO ? depth : depth * -1)
      }
      
      var bestResult = isO ? Int.max : Int.min
      
      for move in (board.indices.filter {board[$0] == .empty}){
         
         var testBoard = board
         testBoard[move] = isO ? .o : .x
         
         let result = self.miniMax(testBoard, depth: depth + 1, isO: !isO)
         
         if isO {
            bestResult = min(bestResult,result)
         }else{
            bestResult = max(bestResult,result)
         }
      }
      return bestResult
   }
   func findBestMove(_ board : [SpaceStatus]) -> Int {
      var bestResult = Int.max
      var bestMove = -1
      for move in (board.indices.filter {board[$0] == .empty}){
         var testBoard = board
         testBoard[move] = .o
         let result = self.miniMax(testBoard, depth: 1, isO: false)
         if result < bestResult{
            bestResult = result
            bestMove = move
         }
      }
      return bestMove
   }
}
struct ContentView: View {
   @State var game = TicTacToe()
   var body: some View {
      VStack{
         Text("YOU: \(self.game.scores.0) COMP: \(self.game.scores.1) DRAW: \(self.game.scores.2)\n\(game.gameState.text)")
            .font(.subheadline)
            .fontWeight(.bold)
            .frame(height:40)
            .multilineTextAlignment(.center)
         VStack{
            ForEach(0..<3) { row in // create number of rows
               HStack {
                  ForEach(0..<3) { column in // create 3 columns
                     SpaceButton(spaceStatus: self.$game.board[row * 3 + column])
                  }
               }
            }
         }.disabled(self.game.gameState != .xTurn) // (.oTurn || .xTurn)
         Button(action:{
            self.game.gameState = .oTurn
            self.game.board = Array(repeating: SpaceStatus.empty, count: 9)
         }) {  Text("Reset") }
      }
      .padding()
        .background(Color.gray)
         
      
   }
}
struct SpaceButton: View{
   
   @Binding var spaceStatus: SpaceStatus
   var body: some View {
      
      ZStack {
        
         Button(action: {
            self.spaceStatus = .x
         }) {
            Rectangle().frame(width: 100, height: 100, alignment: .center)
            .cornerRadius(20)
            .shadow(color: Color.white.opacity(0.2), radius: 1, x: 3, y: 3)
            .shadow(color: Color.black.opacity(0.6), radius: 1, x: -1, y: -1)
         }
         .buttonStyle(PlainButtonStyle())
         .disabled(spaceStatus != .empty)
         Text(spaceStatus.rawValue)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(spaceStatus == .x ? .blue : .red)
            .allowsHitTesting(false)
            .shadow(color: .black, radius: 1, x: 1, y: 1)
      }
   }
}
struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
